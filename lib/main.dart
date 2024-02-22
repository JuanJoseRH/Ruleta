import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ruletafirebase/src/screens/agregarActividad.dart';
import 'package:ruletafirebase/src/screens/edit_actividad.dart';
import 'package:ruletafirebase/src/screens/ruletaPersonalizada.dart';
import 'package:ruletafirebase/src/screens/ruletaView.dart';
import 'package:ruletafirebase/src/screens/ver_actividad.dart';
import 'package:ruletafirebase/src/screens/ver_lista.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruleta',
      routes: {
        '/personalizada': (BuildContext context) => RuletaPersonalizada(),
        '/agregarActividad': (BuildContext context) => AgregarActividad(),
        '/editarActividad': (BuildContext context) => EditarActividad(),
        '/verLista': (BuildContext context) => VerListado(),
        '/verActividades': (BuildContext context) => VerActividades(),
      },
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    Orientation horientacion = MediaQuery.of(context).orientation;
    double width = MediaQuery.of(this.context).size.width;
    //double height = MediaQuery.of(this.context).size.height;

    Container btnSalidas = Container(
      padding: EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
            padding: EdgeInsets.all(20),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RuletaView(
                  tipoRuleta: "Salidas",
                ),
              ),
            );
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInImage(
                  placeholder: AssetImage('asset/icono/activity_indicator.gif'),
                  image: AssetImage('asset/image/salidas.png'),
                  fadeInDuration: Duration(milliseconds: 100),
                ),
                Text(
                  "Salidas",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

    Container btnCasa = Container(
      padding: EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RuletaView(
                  tipoRuleta: "Casa",
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
            padding: EdgeInsets.all(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInImage(
                placeholder: AssetImage('asset/icono/activity_indicator.gif'),
                image: AssetImage('asset/image/casa.png'),
                fadeInDuration: Duration(milliseconds: 100),
              ),
              Text(
                "Casa",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )
            ],
          ),
        ),
      ),
    );

    Container personalizada = Container(
      padding: EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/personalizada',
            );
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
            padding: EdgeInsets.all(20),
          ),
          child: Text(
            "Personalizada",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );

    Padding lista = Padding(
      padding: EdgeInsets.all(20),
      child: ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          Text(
            "Ruletas",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          btnSalidas,
          btnCasa,
          personalizada,
        ],
      ),
    );

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF102E89),
              Color(0xFF020818),
            ],
          ),
        ),
        child: horientacion == Orientation.portrait
            ? lista
            : ((width / 2) < 230)
                ? lista
                : Center(
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        children: [
                          Text(
                            "Ruletas",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: (width / 2.1),
                                child: btnSalidas,
                              ),
                              Container(
                                width: (width / 2.1),
                                child: btnCasa,
                              ),
                            ],
                          ),
                          personalizada,
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
