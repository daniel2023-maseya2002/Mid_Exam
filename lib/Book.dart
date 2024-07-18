class Book {
  final int? id;
  final String title;
  final String author;
  final DateTime date;
  final double rating;

  Book({this.id, required this.title, required this.author, required this.date, required this.rating});

  factory Book.fromMap(Map<String, dynamic> json) => new Book(
    id: json['id'],
    title: json['title'],
    author: json['author'],
    date: DateTime.parse(json['date']),
    rating: json['rating'],
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'author': author,
      'date': date.toIso8601String(),
      'rating': rating,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
