import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proyectoapp/home.dart';
import 'package:proyectoapp/registro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MiApp extends StatelessWidget{
  @override
  Widget build(BuildContext){
    return MaterialApp(
    home: Login(),
    initialRoute: '/',
    routes:{
      //'/': (context) => Login(),
      '/home': (context) => Home(),
      '/registro': (context) => RegistrationScreen(),
    }
  );
  }
}

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background4.png'),
                  fit: BoxFit.fill
                )
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    child: Container(
                      margin: EdgeInsets.only(top:50),
                      child: Center(
                        child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                      )
                    )
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(30.0),
              child:Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(239, 127, 26, .2),
                          blurRadius: 20.0,
                          offset: Offset(0, 10)
                        )
                      ]
                    ),
                    child: Column(
                      children: <Widget> [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey[100]))
                          ),
                          child: new TextField(
                            decoration: new InputDecoration(
                              border: InputBorder.none,
                              hintText: "Correo",
                              hintStyle: TextStyle(color: Colors.grey[400])
                            ),
                          )
                        ),
                        /*Container(  
                          child: new RaisedButton(
                            child: new Text("ingresar",style: new TextStyle(color: Colors.white),),
                            color: Colors.deepPurple,
                            onPressed:ingresar,
                          )
                        ),*/
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Contraseña",
                              hintStyle: TextStyle(color: Colors.grey[400])
                            ),
                          )
                        )
                      ],
                    )
                  ),
                  SizedBox(height: 30,),
                  Container(
                    height: 50,
                    /*decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors:[
                          Color.fromRGBO(255, 114, 21, 1),
                          Color.fromRGBO(255, 114, 21, 1)
                        ]
                      )
                    ),*/
                    child: Center(
                      
                      child: RaisedButton(
                        child:Text("Ingresar",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) ,
                        onPressed: (){
                          Navigator.pushNamed(context, '/home');
                        },
                         shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Color.fromRGBO(255, 114, 21, 1))
                        ),
                        padding: EdgeInsets.all(10.0),
                        
                        color: Color.fromRGBO(255, 114, 21, 1),
                      ),
                      
                    )
                  ),
                  /*Container(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: query.snapshots(),
                      builder: (context, stream){
                        if(stream.connectionState == ConnectionState.waiting){
                          return Center(child: CircularProgressIndicator());
                        }

                        if(stream.hasError){
                          return Center(child: Text(stream.error.toString()));
                        }
                        QuerySnapshot querySnapshot = stream.data;
                        return ListView(
                          children: <Widget>[
                            for(var Docs in querySnapshot.docs) ListTile(title: new Text(Docs.data()['correo']),)
                          ]
                        );
                      },
                    )
                  ),*/
                  SizedBox(height: 50,),
                  new InkWell(
                    child: Text("Registrarse", style: TextStyle(color: Color.fromRGBO(218, 122, 59, 1), fontWeight: FontWeight.bold)),
                    onTap: (){
                          Navigator.pushNamed(context, '/registro');
                        },
                  ), 
                ],
              )
            )
          ]
        )
      ),
    );
  }
}