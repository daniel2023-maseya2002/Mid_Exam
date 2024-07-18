import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'AddBookScreen.dart';
import 'EditBookScreen.dart';
import 'BookDetailScreen.dart';
import 'Book.dart';
import 'database_helper.dart';

class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  late Future<List<Book>> _bookList;
  String _currentSortCriteria = 'title';  // Default sorting criteria
  List<Book> _filteredBooks = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshBookList();
  }

  void _refreshBookList() {
    setState(() {
      _bookList = DatabaseHelper().getBooks().then((books) {
        _filteredBooks = books;
        return books;
      });
    });
  }

  void _addNewBook(Book book) async {
    await DatabaseHelper().insert(book);
    _refreshBookList();
  }

  void _editBook(Book updatedBook) async {
    await DatabaseHelper().update(updatedBook);
    _refreshBookList();
  }

  void _deleteBook(int id) async {
    await DatabaseHelper().delete(id);
    _refreshBookList();
  }

  void _editBookDialog(Book book) async {
    final editedBook = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditBookScreen(book: book)),
    );

    if (editedBook != null) {
      _editBook(editedBook);
    }
  }

  void _showDeleteConfirmationDialog(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Book'),
        content: Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteBook(book.id!);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _filterBooks(String query) {
    setState(() {
      _searchQuery = query;
      _bookList.then((books) {
        _filteredBooks = books.where((book) {
          return book.title.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    });
  }

  List<Book> _sortBooks(List<Book> books) {
    switch (_currentSortCriteria) {
      case 'title':
        books.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'author':
        books.sort((a, b) => a.author.compareTo(b.author));
        break;
      case 'rating':
        books.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'date':
        books.sort((a, b) => b.date.compareTo(a.date));
        break;
    }
    return books;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book List'),
        actions: [
          DropdownButton<String>(
            value: _currentSortCriteria,
            onChanged: (String? newValue) {
              setState(() {
                _currentSortCriteria = newValue!;
                _refreshBookList();
              });
            },
            items: <String>['title', 'author', 'rating', 'date']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('Sort by ${value[0].toUpperCase()}${value.substring(1)}'),
              );
            }).toList(),
          ),
        ],
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
                'Search Books',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  _filterBooks(value);
                },
                decoration: InputDecoration(
                  hintText: 'Enter book title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Book>>(
        future: _bookList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          } else {
            final sortedBooks = _sortBooks(_filteredBooks);
            return ListView.builder(
              itemCount: sortedBooks.length,
              itemBuilder: (context, index) {
                final book = sortedBooks[index];
                return Card(
                  margin: EdgeInsets.all(10.0),
                  color: _getColor(index),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10.0),
                    title: Text(book.title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.author),
                        Text('${DateFormat.yMMMd().format(book.date)}'),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow),
                            Text(book.rating.toString()),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editBookDialog(book);
                        } else if (value == 'delete') {
                          _showDeleteConfirmationDialog(book);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.black),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newBook = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBookScreen()),
          );

          if (newBook != null) {
            _addNewBook(newBook);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(10.0),
          color: _getColor(index),
          child: ListTile(
            contentPadding: EdgeInsets.all(10.0),
            title: Text('Title Placeholder', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Author Placeholder', style: TextStyle(color: Colors.grey)),
                Text('Date Placeholder', style: TextStyle(color: Colors.grey)),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.grey),
                    Text('Rating Placeholder', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            onTap: () {
              // Do nothing on tap placeholder
            },
          ),
        );
      },
    );
  }

  Color _getColor(int index) {
    switch (index % 3) {
      case 0:
        return Colors.blue.shade100;
      case 1:
        return Colors.red.shade100;
      case 2:
        return Colors.orange.shade100;
      default:
        return Colors.white;
    }
  }
}
