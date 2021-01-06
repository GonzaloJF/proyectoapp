import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/*funcion size para los margenes de la pagina*/
class Commonthings {
  static Size size;
}

/*statefull widget para inicializar la funcion*/
class Newpost extends StatefulWidget {
  final String id;
  const Newpost({this.id});
  @override
  _NewpostState createState() => _NewpostState();
}

/* funcion selectSource sirve para poder elegir entre la camara y la galeria  */
enum SelectSource { camara, galeria }

/*inicio del newpost  */
class _NewpostState extends State<Newpost> {
  //los tipos de ddatos que se utilizaran dentro del newpost
  File _foto;
  String urlFoto;
  bool _isInAsyncCall = false;
  String recetas;
  String userID = "";
  String userEmail = "";
  List<DropdownMenuItem<String>>
      _categoria_Items; //genera una lista de las categorias que existen.
  String _itemCategoria;

/* funcion que sirve para iniciar algunas funciones y poder utilizarlas como la que captura info del usuario y las categorias */
  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    _categoria_Items = getCategoria();
    _itemCategoria = _categoria_Items[0].value;
  }

/* toma los datos de la coleccion de categorias */
  getData() async {
    return await FirebaseFirestore.instance.collection('categorias').get();
  }

/* toma los datos del usuario para verificar si esta conectado */
  fetchUserInfo() async {
    User getUser = FirebaseAuth.instance.currentUser;
    userID = getUser.uid;
    userEmail = getUser.email;
  }

/* controladores de texto para saber que los textos no estan vacios */
  TextEditingController recetaInputController;
  TextEditingController nombreInputController;
  TextEditingController imageInputController;
  TextEditingController ingredientesInputController;
/* mas tipos de datos y se instancia la db y formkey */
  String id;
  final db = Firestore.instance;
  final _formKey = GlobalKey<FormState>();
  String nombre;
  String uid;
  String receta;
  String usuario;
  String ingredientes;

/* inicio de la funcion de captura de imagen */
  Future CaptureIamgen(SelectSource opcion) async {
    File image;

    opcion == SelectSource.camara
        ? image = await ImagePicker.pickImage(source: ImageSource.camera)
        : image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _foto = image;
    });
  }

/* se realiza la captura de datos de las categorias para hacer el dropdown */
  List<DropdownMenuItem<String>> getCategoria() {
    List<DropdownMenuItem<String>> items = List();
    QuerySnapshot dataCategorias;
    getData().then((data) {
      dataCategorias = data;
      dataCategorias.docs.forEach((obj) {
        print('${obj.id} ${obj['nombre']}');
        items.add(DropdownMenuItem(
          value: obj.id,
          child: Text(obj['nombre'], style: TextStyle(color: Colors.black)),
        ));
      });
    }).catchError((error) => print('hay un error.....' + error));

    items.add(DropdownMenuItem(
      value: '0',
      child: Text(
        '- Seleccione -',
        style: TextStyle(color: Colors.black),
      ),
    ));

    return items;
  }

/* se hace la  funcion con la alerta de dialogo donde te hace seleccionar que se ocupara para agregar la imagen de la receta */
  Future getImage() async {
    AlertDialog alerta = new AlertDialog(
      content: Text('Seleccione donde desea capturar la imagen'),
      title: Text('seleccione imagen'),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            CaptureIamgen(SelectSource.camara);
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Row(
            children: <Widget>[Text('Camcara'), Icon(Icons.camera)],
          ),
        ),
        FlatButton(
          onPressed: () {
            CaptureIamgen(SelectSource.galeria);
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Row(
            children: <Widget>[Text('Galeria'), Icon(Icons.image)],
          ),
        )
      ],
    );
    showDialog(context: context, child: alerta);
  }

/* divide los espacios dentro de la pagina  */
  Widget divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Container(
        width: 0.8,
        color: Colors.orange,
      ),
    );
  }

/* valida el formulario para poder pasar a la funcion envio */
  bool _validarlo() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

/* en esta funcion se procede a hacer todo el guardado de la receta en la bace de datos  */
  enviar() async {
    if (_validarlo()) {
      setState(() {
        _isInAsyncCall = true;
      });
      if (_foto != null) {
        final _storage = FirebaseStorage
            .instance; //se instancia el espacio que tendra en la base de datos
        var fireStoreRef =
            await _storage // esta es la referencia al espacio instanciado anteriormente
                .ref()
                .child('usuario')
                .child(userID) //verifica si es realmente el usuario id
                .child('recetas') // da nombre a la coleccion de datos
                .child('$nombre.jpg')
                .putFile(_foto);

        var downloadUrl = await fireStoreRef.ref
            .getDownloadURL(); //captura el url de la imagen tomada
        urlFoto = downloadUrl;
        setState(() {
          Firestore.instance.collection('recetas').add({
            //aqui agrega los demas datos a la intancia de las recetas.
            'uid': userID,
            'nombre': nombre,
            'image': urlFoto,
            'ingredientes': ingredientes,
            'receta': receta,
            'categorias': _categoria_Items
          });
          /* .then((value) => Navigator.of(context).pop())
              .catchError((onError) =>
                  print('error en registrar la receta del usuario'));*/
          _isInAsyncCall = false;
        });
      } else {
        Firestore.instance.collection('recetas').add({
          'uid': userID,
          'nombre': nombre,
          'image': urlFoto,
          'ingredientes': ingredientes,
          'receta': receta,
          'categoria': _categoria_Items
        });
        /*.then((value) => Navigator.pushNamed(context, '/home')
            .catchError(
                (onError) => print('error al registrar la receta de usuario')));*/
        _isInAsyncCall = false;
      }
    }
  }

/* aqui se contruye la vista con cada uno de los espacios para el formulario
demas de hacer todos las validaciones de que no hayan espacios en blanco, etc. */
  @override
  Widget build(BuildContext context) {
    Commonthings.size = MediaQuery.of(context).size;

    return Scaffold(
        body: ModalProgressHUD(
      inAsyncCall: _isInAsyncCall,
      opacity: 0.5,
      dismissible: false,
      progressIndicator: CircularProgressIndicator(),
      color: Colors.blueGrey,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 10, right: 15),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    child: GestureDetector(
                      onTap: getImage,
                    ),
                    margin: EdgeInsets.only(top: 20),
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1.0, color: Colors.black),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: _foto == null
                                ? AssetImage('assets/images/azucar.gif')
                                : FileImage(_foto))),
                  )
                ],
              ),
              Text('click para cambiar foto'),
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'titulo de la receta',
                  fillColor: Colors.grey[300],
                  filled: true,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'porfavor ingrese algún titulo aquí';
                  }
                },
                onSaved: (value) => nombre = value.trim(),
              ),
              DropdownButtonFormField(
                validator: (value) =>
                    value == '0' ? 'Debe seleccionar una categoria' : null,
                decoration: InputDecoration(
                    labelText: 'Categoria',
                    icon: Icon(FontAwesomeIcons.filter, color: Colors.black),
                    labelStyle: TextStyle(color: Colors.black)),

                value: _itemCategoria,
                items: _categoria_Items,
                onChanged: (value) {
                  setState(() {
                    _categoria_Items = value;
                  });
                }, //selecciona una categoria item.

                onSaved: (value) => _categoria_Items = value,
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'ingredientes de la receta',
                  fillColor: Colors.grey[300],
                  filled: true,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'porfavor ingrese algún ingrediente aquí';
                  }
                },
                onSaved: (value) => ingredientes = value.trim(),
              ),
              TextFormField(
                maxLines: 5,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'receta',
                  fillColor: Colors.grey[300],
                  filled: true,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'porfavor ingrese alguna receta aquí';
                  }
                },
                onSaved: (value) => receta = value,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                      child: Text('Crear Receta',
                          style: TextStyle(color: Colors.white)),
                      color: Colors.green,
                      onPressed: () {
                        enviar();
                        Navigator.pushNamed(context, '/home');
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    ));
  }
}
