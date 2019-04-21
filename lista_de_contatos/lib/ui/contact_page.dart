import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_de_contatos/helper/contact_helper.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact});



  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  Contact _editContact;
  bool _userEdited = false;

  @override
  void initState(){


    super.initState();

    if(widget.contact  == null)
      _editContact = Contact();
    else{
      _editContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editContact.name;
      _emailController.text = _editContact.email;
      _phoneController.text = _editContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:  _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editContact.name ?? "Novo contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(_editContact.name != null && _editContact.name.isNotEmpty) {
              Navigator.pop(context, _editContact);
            }
            else{
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red ,

        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editContact.image != null ?
                          FileImage(File(_editContact.image )) :
                          AssetImage("images/person.png")
                      )
                  ),
                ),
                onTap: (){
                  ImagePicker.pickImage(source: ImageSource.gallery).then((file){
                    if(file == null) return;
                    setState(() {
                      _editContact.image = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: _nameController,
                focusNode:  _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text){
                  _userEdited = true;
                  setState(() {
                    _editContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                onChanged: (text){
                  _userEdited = true;
                  _editContact.email = text;
                },
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
                onChanged: (text){
                  _userEdited = true;
                  _editContact.phone = text;
                },
              )
            ],
          ),
        ),
      ),
    );
  }
  
  Future<bool> _requestPop(){
    if(_userEdited) {
      showDialog(context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Discard all changes?"),
              content: Text("Confirm  to discard all changes"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Confirm"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
      return Future.value(false);
    } else{
      return Future.value(true);
    }
  }
}
