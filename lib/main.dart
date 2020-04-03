import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MaterialApp(
  home: MyApp(),
));

class MyApp extends StatefulWidget{
  @override
  _AppState createState()=>_AppState();
}
class _AppState extends State<MyApp>{
//VARIABLES DE CONTROL
  List _salidas;
  File _Imagen;
  bool _isLoading = false;

  @override
  void initState(){
    super.initState();
    _isLoading = true;
    loadModel().then((value){
      setState(() {
        _isLoading = false;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
// TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("IMAGE RECOGNITION DISNEY"),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: _isLoading ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ): Container(
        width: MediaQuery.of(context).size.width,//Ajusta a ancho de pantalla
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _Imagen == null ? Container():Image.file(_Imagen),
            SizedBox(
              height: 20,
            ),
            _salidas != null ? Text("${_salidas[0]["label"]}",
              style: TextStyle(
                color: Colors.blue[900],
                fontSize: 30.0,
                background: Paint()..color = Colors.white,
              ),
            )
                : Container()
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.blue[800],
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            child: Icon(Icons.camera_alt),
              label: "Tomar Foto",
              backgroundColor: Colors.lightBlue[600],
              onTap: getImage
          ),

          SpeedDialChild(
              child: Icon(Icons.insert_photo),
              label: "Subir Imagen",
              backgroundColor: Colors.lightBlue[300],
              onTap: pickImage,
          )
        ],
      ),
    );
  }

  //Tomar foto desde camara
  getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if(image == null) return null;
    setState(() {
      _isLoading = true;
      _Imagen = image;
    });

    clasificar(image);
  }


//Cargar Imagen desde Galería
  pickImage() async {
    var imagen = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(imagen == null) return null;
    setState(() {
      _isLoading = true;
      _Imagen = imagen;
    });

    clasificar(imagen);
  }

  clasificar(File image) async{
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 5,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _isLoading = false;
      _salidas = output;
    });
  }

//Cargar Modelo
  loadModel() async{
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }
  @override
  void dispose(){
    Tflite.close();
    super.dispose();
  }


}
