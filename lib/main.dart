import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MaterialApp(
    title: "flutter Demo",
    theme: ThemeData(
      primaryColor: Colors.blue,
    ),
    debugShowCheckedModeBanner: false,
    home: const HomePage(),
    routes: {'/new-contact': (context) => const NewContactView()},
  ));
}

// class for handle contact
class Contact {
  final String id;
  final String name;
  Contact({
    required this.name,
  }) : id = const Uuid().v4();
}

// contact book functions class
class ContactBook extends ValueNotifier<List<Contact>> {
  ContactBook._sharedInstance() : super([]); // initialized empyt list
  static final ContactBook _shared =
      ContactBook._sharedInstance(); // singleton instance
  // factory constructor return already have instance, not create new instance
  factory ContactBook() => _shared;

  final List<Contact> _contacts = [];

  int get length => value.length;

  void add({required Contact contact}) {
    // this is also work
    // < ------------------------
    // value.add(contact);
    // notifyListeners();
    // ----------------------->

    // this usage is better
    final contacts = value;
    contacts.add(contact);
    notifyListeners();
  }

  void remove({required Contact contact}) {
    final contacts = value;
    if (_contacts.contains(contact)) {
      contacts.remove(contact);
      notifyListeners();
    }
  }

  // retrieve contacts with index
  Contact? contact({required int atIndex}) =>
      value.length > atIndex ? value[atIndex] : null;
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Home Page"),
      ),
      body: ValueListenableBuilder(
        valueListenable: ContactBook(),
        builder: (contact, value, child) {
          final contacts = value as List<Contact>;
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Dismissible(
                onDismissed: (direction) {
                  // not the right way
                  // contacts.remove(contact);
                  ContactBook().remove(contact: contact);
                },
                key: ValueKey(contact.id),
                child: Material(
                  color: Colors.white,
                  elevation: 6.0,
                  child: ListTile(
                    title: Text(contact.name),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed('/new-contact');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// add new contact to contact book
class NewContactView extends StatefulWidget {
  const NewContactView({Key? key}) : super(key: key);

  @override
  State<NewContactView> createState() => _NewContactViewState();
}

class _NewContactViewState extends State<NewContactView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    // TODO: implement initState
    _controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new contact"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
                hintText: 'Enter a new contact name here'),
          ),
          TextButton(
              onPressed: () {
                final contact = Contact(name: _controller.text);
                ContactBook().add(contact: contact);
                Navigator.of(context).pop();
              },
              child: const Text('Add contact'))
        ],
      ),
    );
  }
}
