import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_de_contatos/helper/contact_helper.dart';
import 'package:lista_de_contatos/ui/contact_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

enum OrderOptions{orderAZ, orderZA}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();
  List<Contact> listContact = List();

  @override
  void initState(){
    super.initState();
    print("lista de contatos");

    _getAllContacts();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (contet) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A a Z"), value: OrderOptions.orderAZ,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z a A"), value: OrderOptions.orderZA,
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: listContact.length,
        itemBuilder: (context, index){
          print(context);
          return _contentCard(context, index);
        },
      ),
    );
  }

  Widget _contentCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: listContact[index].image != null ?
                        FileImage(File(listContact[index].image )) :
                                  AssetImage("images/person.png")
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      listContact[index].name ?? "",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      listContact[index].email ?? "",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      listContact[index].phone ?? "",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: (){
        _showOptions(context, index);
      },
    );
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderAZ:
        listContact.sort( (a,b){
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderZA:
        listContact.sort( (a,b){
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }

    setState((){});
  }

  void _showOptions( BuildContext context, int index){
    showModalBottomSheet(context: context, builder: (context){
      return BottomSheet(
        onClosing: (){},
        builder: (context){
          return Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child:  FlatButton(
                        child: Text(
                            "Ligar",
                            style: TextStyle(color: Colors.red, fontSize: 20.0)),
                            onPressed: (){
                              Navigator.pop(context);
                              launch("tel:${listContact[index].phone}");
                            },
                    )
                ),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child:  FlatButton(
                        child: Text(
                            "Editar",
                            style: TextStyle(color: Colors.red, fontSize: 20.0)),
                      onPressed: (){
                        Navigator.pop(context);
                        _showContactPage(contact: listContact[index]);
                      },
                    )
                ),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child:  FlatButton(
                        child: Text(
                            "Excluir",
                            style: TextStyle(color: Colors.red, fontSize: 20.0)),
                      onPressed: (){
                        setState(() {
                          helper.deleteContact(listContact[index].id);
                          listContact.removeAt(index);
                          Navigator.pop(context);
                        });
                      }
                      ,
                    )
                )
              ],
            ),
          );
        },
      );
    });
  }

  void _showContactPage({Contact contact}) async{
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context)=> ContactPage(contact: contact))
    );

    if(recContact != null){
      if(contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts(){
    helper.getAllCOntact().then((list){
      setState((){
        listContact = list;
        print(listContact);
      });

    });
  }
}
