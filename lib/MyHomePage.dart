import 'package:flutter/material.dart';
import 'BookListScreen.dart';
import 'AddBookScreen.dart';
import 'EditBookScreen.dart';
import 'SettingsScreen.dart';
import 'Book.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Book? _recentlyAddedBook;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyBook Library'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('View Book List'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookListScreen()),
                );
              },
            ),
            if (_recentlyAddedBook != null) ...[
              Divider(),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Book'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditBookScreen(book: _recentlyAddedBook!),
                    ),
                  ).then((updatedBook) {
                    if (updatedBook != null) {
                      setState(() {
                        _recentlyAddedBook = updatedBook;
                      });
                    }
                  });
                },
              ),
            ],
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: BookListScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newBook = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBookScreen()),
          );
          if (newBook != null) {
            setState(() {
              _recentlyAddedBook = newBook;
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
