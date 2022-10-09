import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Image Picker Demo',
      home: MyHomePage(title: 'Image Picker Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<XFile>? _imageFileList;
  XFile? pickedFile;

  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;

  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  void upload(XFile? pickedFile) async {
    if (pickedFile == null) return;

    String filepath = pickedFile!.path;
    final base64 = base64Encode(File(filepath).readAsBytesSync());
    final nbrbase64 = await File(filepath).readAsBytes();
    // print("base6444444444444444444");
    // print(base64);
    // print(nbrbase64);

    String imagename = filepath.split("/").last;
    // print("image nammmmeee");
    // print(imagename);

    String link =
        'https://timserver.northeurope.cloudapp.azure.com/GmaoProWebApi/api/UploaderFile/Upload';
    var uri = Uri.parse(link);
    var request = http.MultipartRequest('POST', Uri.parse(link));
    request.files.add(await http.MultipartFile.fromPath("", filepath));
    request.headers.addAll({
      'Content-type': 'multipart/form-data',
      'authorization': 'Bearer ' +
          '-jMhx14-3EhBvCpnCbnPFxScmg7lsAyztMyjhw4wC9zara7IjZWOk8MZOONrraEhimHQKzILnN5k19xkMaplIykrBU1PdR2A-45JTlTJwCu9bGLeazIzlWZifargJYqU8GmpgWyxzr8D-F2lYIFXClTotVtNLJyZLFkCnU4aqGsbjlE37opEjgCxfLCSfo8S_TpanT-L1N8NtGGIB4-xSWmNJozuBvzUd2Z61rObcZ8RgNtd32iKUAf1l8CQ-8L6wunEY3w_brFjiYu-1xA_BSGIUBcCIicJDt4IEPQ8vKmb8Z3FZOBumQKAXmQHG3tiRhoC27mtISk5mSadsWUuVPHsOY8D31l9o4dh5WOu2auHZbDrxwds5FNUth-4qzT5yRzYkvitsdTAJYslz45rfa1smg5vISWL3T9GSAYdRciBRGiimmEPfO2bs7Fv5V0mGSFgqPMI7I4nWNH_8cIJyvOkK0rrkV3f96x6CFMY2BY',
    });

    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    print(respStr);
    // return response;

    // if (response.statusCode == 200) {
    //   print(response);
    //   print("yesssss");
    // } else {
    //   print("NOOOOOOOOOOOOOOO");
    // }
  }

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );
      setState(() {
        print("pickedFileeeeeeeeeeeeeeeeeeeee");
        print(pickedFile!.path);
        _setImageFileListFromFile(pickedFile);

        upload(pickedFile);
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileList != null) {
      return Semantics(
        label: 'image_picker_example_picked_images',
        child: ListView.builder(
          key: UniqueKey(),
          itemBuilder: (BuildContext context, int index) {
            return Semantics(
              label: 'image_picker_example_picked_image',
              child: kIsWeb
                  ? Image.network(_imageFileList![index].path)
                  : Image.file(File(_imageFileList![index].path)),
            );
          },
          itemCount: _imageFileList!.length,
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _handlePreview() {
    return _previewImages();
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.files == null) {
          _setImageFileListFromFile(response.file);
        } else {
          _imageFileList = response.files;
        }
      });
    }

    _retrieveDataError = response.exception!.code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Text(
                        'You have not yet picked an image.',
                        textAlign: TextAlign.center,
                      );
                    case ConnectionState.done:
                      return _handlePreview();
                    default:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image/video error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return const Text(
                          'You have not yet picked an image.',
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              )
            : _handlePreview(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Semantics(
            label: 'image_picker_example_from_gallery',
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(ImageSource.gallery, context: context);
              },
              heroTag: 'image0',
              tooltip: 'Pick Image from gallery',
              child: const Icon(Icons.photo),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(ImageSource.camera, context: context);
              },
              heroTag: 'image2',
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.mail),
            ),
          ),
        ],
      ),
    );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}
