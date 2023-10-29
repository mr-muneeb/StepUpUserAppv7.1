// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/address_model.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/data/model/response/response_model.dart';
import 'package:flutter_grocery/data/repository/location_repo.dart';
import 'package:flutter_grocery/helper/api_checker.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_webservice/places.dart';

class LocationProvider with ChangeNotifier {
  final SharedPreferences? sharedPreferences;
  final LocationRepo? locationRepo;

  LocationProvider({required this.sharedPreferences, this.locationRepo});

  Position _position = Position(
    longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1,
    altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,
    altitudeAccuracy: 0, headingAccuracy: 0,
  );
  Position _pickPosition = Position(
    longitude: 0, latitude: 0, timestamp: DateTime.now(),
    accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,
    altitudeAccuracy: 0, headingAccuracy: 0,
  );
  bool _loading = false;
  bool get loading => _loading;
  // TextEditingController _locationController = TextEditingController();
  //
  // TextEditingController get locationController => _locationController;
  Position get position => _position;
  Position get pickPosition => _pickPosition;
  String? _address = '';
  String? _pickAddress = '';
  final String _currentAddressText = '';
  String get currentAddressText => _currentAddressText;

  String? get address => _address;
  String? get pickAddress => _pickAddress;
  final List<Marker> _markers = <Marker>[];

  List<Marker> get markers => _markers;

  bool _buttonDisabled = true;
  bool _changeAddress = true;
  List<Prediction> _predictionList = [];
  bool _updateAddAddressData = true;

  bool get buttonDisabled => _buttonDisabled;

  set setAddress(String? addressValue)=> _address = addressValue;

  GoogleMapController? mapController;
  CameraPosition? cameraPosition;
  bool isUpdateAddress = true;

  // for get current location
  void getCurrentLocation(BuildContext context, bool fromAddress, {GoogleMapController? mapController}) async {
    _loading = true;
    notifyListeners();

    Position myPosition;
    try {
      Position newLocalData = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      myPosition = newLocalData;
    }catch(e) {
      myPosition = Position(
        latitude: double.parse('0'),
        longitude: double.parse('0'),
        timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,
        altitudeAccuracy: 0, headingAccuracy: 0,
      );
    }
    if(fromAddress) {
      _position = myPosition;
    }else {
      _pickPosition = myPosition;
    }
    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(myPosition.latitude, myPosition.longitude), zoom: 17),
      ));
    }
    // String _myPlaceMark;
    String getAddress = await getAddressFromGeocode(LatLng(myPosition.latitude, myPosition.longitude));
    if(fromAddress) {
      _address = placeMarkToAddress(getAddress);
    }
    _loading = false;
    notifyListeners();
  }

  void updatePosition(CameraPosition? position, bool fromAddress, String? address, bool forceNotify) async {
    if(_updateAddAddressData) {
      _loading = true;
      if(forceNotify) {
        notifyListeners();
      }

      try {
        if (fromAddress) {
          _position = Position(
            latitude: position!.target.latitude, longitude: position.target.longitude, timestamp: DateTime.now(),
            heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1, altitudeAccuracy: 0, headingAccuracy: 0,
          );
        } else {
          _pickPosition = Position(
            latitude: position!.target.latitude, longitude: position.target.longitude, timestamp: DateTime.now(),
            heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1,
            altitudeAccuracy: 0, headingAccuracy: 0,
          );
        }
        if (_changeAddress) {
          String addressFromGeocode = await getAddressFromGeocode(LatLng(position.target.latitude, position.target.longitude));
          fromAddress ? _address = addressFromGeocode : _pickAddress = addressFromGeocode;

        } else {
          _changeAddress = true;
        }
      } catch (e) {
        debugPrint('error ==> $e');
      }
      _loading = false;

      if(forceNotify){
        notifyListeners();
      }

    }else {
      _updateAddAddressData = true;
    }
  }


  // delete usser address
  void deleteUserAddressByID(int? id, int index, Function callback) async {
    ApiResponse apiResponse = await locationRepo!.removeAddressByID(id);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _addressList!.removeAt(index);
      callback(true, 'Deleted address successfully');
      notifyListeners();
    } else {
      callback(false, ApiChecker.getError(apiResponse).errors![0].message ?? '');
    }
  }

  final bool _isAvaibleLocation = false;

  bool get isAvaibleLocation => _isAvaibleLocation;

  // user address
  List<AddressModel>? _addressList;

  List<AddressModel>? get addressList => _addressList;

  Future<ResponseModel?> initAddressList() async {
    ResponseModel? responseModel;
    _addressList = null;
    ApiResponse apiResponse = await locationRepo!.getAllAddress();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _addressList = [];
      apiResponse.response!.data.forEach((address) => _addressList!.add(AddressModel.fromJson(address)));
      responseModel = ResponseModel(true, 'successful');
    } else {
      _addressList = [];
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
    return responseModel;
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? _errorMessage = '';
  String? get errorMessage => _errorMessage;
  String? _addressStatusMessage = '';
  String? get addressStatusMessage => _addressStatusMessage;
  updateAddressStatusMessage({String? message}){
    _addressStatusMessage = message;
  }

  updateErrorMessage({String? message}){
    _errorMessage = message;
  }

  Future<ResponseModel> addAddress(AddressModel addressModel, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    _errorMessage = '';
    _addressStatusMessage = null;
    ApiResponse apiResponse = await locationRepo!.addAddress(addressModel);
    _isLoading = false;
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      initAddressList();
      String? message = map["message"];
      responseModel = ResponseModel(true, message);
      _addressStatusMessage = message;
    } else {

      responseModel = ResponseModel(false, ApiChecker.getError(apiResponse).errors?.first.message);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  // for address update screen
  Future<ResponseModel> updateAddress(BuildContext context, {required AddressModel addressModel, int? addressId}) async {
    _isLoading = true;
    notifyListeners();
    _errorMessage = '';
    _addressStatusMessage = null;
    ApiResponse apiResponse = await locationRepo!.updateAddress(addressModel, addressId);
    _isLoading = false;
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      initAddressList();
      String? message = map["message"];
      responseModel = ResponseModel(true, message);
      _addressStatusMessage = message;
    } else {
      _errorMessage = ApiChecker.getError(apiResponse).errors![0].message;
      responseModel = ResponseModel(false, errorMessage);

    }
    notifyListeners();
    return responseModel;
  }

  // for save user address Section
  Future<void> saveUserAddress({Placemark? address}) async {
    String userAddress = jsonEncode(address);
    try {
      await sharedPreferences!.setString(AppConstants.userAddress, userAddress);
    } catch (e) {
      rethrow;
    }
  }

  String getUserAddress() {
    return sharedPreferences!.getString(AppConstants.userAddress) ?? "";
  }

  // for Label Us
  List<String> _getAllAddressType = [];

  List<String> get getAllAddressType => _getAllAddressType;
  int _selectAddressIndex = 0;

  int get selectAddressIndex => _selectAddressIndex;

  updateAddressIndex(int index, bool notify) {
    _selectAddressIndex = index;
    if(notify) {
      notifyListeners();
    }
  }

  initializeAllAddressType({BuildContext? context}) {
    if (_getAllAddressType.isEmpty) {
      _getAllAddressType = [];
      _getAllAddressType = locationRepo!.getAllAddressType(context: context);
    }
  }

  void setLocation(String? placeID, String? address, GoogleMapController? mapController) async {
    _loading = true;
    notifyListeners();
    PlacesDetailsResponse detail;
    ApiResponse response = await locationRepo!.getPlaceDetails(placeID);
    detail = PlacesDetailsResponse.fromJson(response.response?.data);

    _pickPosition = Position(
      longitude: detail.result.geometry!.location.lat, latitude: detail.result.geometry!.location.lng,
      timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,
      altitudeAccuracy: 0, headingAccuracy: 0,
    );

    _pickAddress = address;
    _address = address;
    _changeAddress = false;

    if(mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
        detail.result.geometry!.location.lat, detail.result.geometry!.location.lng,
      ), zoom: 16)));
    }
    _loading = false;
    notifyListeners();
  }

  void disableButton() {
    _buttonDisabled = true;
    notifyListeners();
  }

  void setAddAddressData(bool isUpdate) {
    _position = _pickPosition;
    _address = _pickAddress;
    _updateAddAddressData = false;
    if(isUpdate){
      notifyListeners();
    }
  }


  void setPickData() {
    _pickPosition = _position;
    _pickAddress = _address;
  }



  Future<String> getAddressFromGeocode(LatLng latLng) async {
    ApiResponse response = await locationRepo!.getAddressFromGeocode(latLng);
    String address = 'Unknown Location Found';
    if(response.response!.statusCode == 200 && response.response!.data['status'] == 'OK') {
      address = response.response!.data['results'][0]['formatted_address'].toString();
    }else {
      ApiChecker.checkApi(response);
    }
    return address;
  }

  Future<List<Prediction>> searchLocation(BuildContext context, String text) async {
    if(text.isNotEmpty) {
      ApiResponse response = await locationRepo!.searchLocation(text);
      if (response.response!.statusCode == 200 && response.response!.data['status'] == 'OK') {
        _predictionList = [];
        response.response!.data['predictions'].forEach((prediction) => _predictionList.add(Prediction.fromJson(prediction)));
      } else {
        ApiChecker.checkApi(response);
      }
    }
    return _predictionList;
  }

  String placeMarkToAddress(String placeMark) {
    return placeMark;
  }


  Future<AddressModel?> getLastOrderedAddress() async {
    AddressModel? addressModel;
    ApiResponse apiResponse = await locationRepo!.getLastOrderedAddress();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200 && apiResponse.response?.data.isNotEmpty) {
      addressModel = AddressModel.fromJson(apiResponse.response?.data);
    }
    return addressModel;
  }

  int? getAddressIndex(AddressModel address){
    int? index;
    if(_addressList != null) {
      for(int i = 0; i < _addressList!.length; i ++) {
        if(_addressList![i].id == address.id) {
          index = i;
          break;
        }
      }
    }
    return index;
  }




}
