import 'dart:convert'; // For jsonEncode / jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Blogs',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BlogListPage(),
    );
  }
}

// ------------------------------------
// BLOG LIST PAGE
// ------------------------------------
class BlogListPage extends StatefulWidget {
  const BlogListPage({Key? key}) : super(key: key);

  @override
  _BlogListPageState createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage> {
  // A list of blog texts
  List<String> _blogs = [];

  @override
  void initState() {
    super.initState();
    _loadBlogs(); // Load blogs from the backend
  }

  // Load blogs from the backend
  Future<void> _loadBlogs() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.111:5000/api/blogs'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _blogs =
            data
                .map((blog) {
                  return {
                    'title':
                        blog['title'].toString(), // Ensure 'title' is a String
                    'content':
                        blog['content']
                            .toString(), // Ensure 'content' is a String
                    'author':
                        blog['author']
                            .toString(), // Ensure 'author' is a String
                  };
                })
                .toList()
                .map((map) => map.values.join('\n\n'))
                .toList(); // Flatten the list
      });
    } else {
      // Handle error (optional)
      debugPrint('Failed to load blogs: ${response.statusCode}');
    }
  }

  // Save the current list of blogs to the backend
  Future<void> _saveBlogs() async {
    final response = await http.post(
      Uri.parse('http://192.168.0.111:5000/api/blogs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'blogs': _blogs}),
    );

    if (response.statusCode != 200) {
      debugPrint('Failed to save blogs: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(
        255,
        244,
        233,
        216,
      ), // Change page background color
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make Scaffold transparent
        // AppBar with increased height & bigger title font
        appBar: AppBar(
          backgroundColor: Colors.brown,
          toolbarHeight: 80.0,
          title: const Text(
            'Blogs',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white, // Title color changed to white
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white, // Arrow color changed to white
          ),
        ),
        body:
            _blogs.isEmpty
                ? const Center(
                  child: Text(
                    'No blogs added yet.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: _blogs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: BlogContainer(
                        blogText: _blogs[index],
                        onReadMore: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BlogDetailPage(
                                    blogText: _blogs[index],
                                    blogIndex: index,
                                    onBlogEdited: _handleBlogEdited,
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFF2EDE5), // Set background color
          child: const Icon(
            Icons.add,
            color: Colors.brown, // Change + symbol color to brown
            size: 32, // Increase icon size
          ),
          onPressed: () async {
            // Navigate to AddBlogPage (in "Add" mode) and wait for result
            final newBlog = await Navigator.push<String>(
              context,
              MaterialPageRoute(builder: (_) => const AddBlogPage()),
            );

            // If a blog was submitted, add it to the list and save
            if (newBlog != null && newBlog.isNotEmpty) {
              setState(() {
                _blogs.add(newBlog);
              });
              await _saveBlogs();
            }
          },
        ),
      ),
    );
  }

  // Called after a blog is edited in BlogDetailPage
  Future<void> _handleBlogEdited(int index, String updatedText) async {
    setState(() {
      _blogs[index] = updatedText;
    });
    await _saveBlogs();
  }
}

// ------------------------------------
// BLOG CONTAINER (ITEM CARD)
// ------------------------------------
class BlogContainer extends StatelessWidget {
  final String blogText;
  final VoidCallback onReadMore;

  const BlogContainer({
    Key? key,
    required this.blogText,
    required this.onReadMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Split the blogText into title and content
    final lines = blogText.split('\n\n');
    final title = lines.isNotEmpty ? lines.first : 'Untitled';
    final content = lines.length > 1 ? lines.sublist(1).join('\n\n') : '';

    // Container with a light background color and a brown shadow
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 2,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: const Color(0xFFFCEBCB),
        border: Border.all(color: Colors.brown, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.brown,
            blurRadius: 8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the title in bold
          Text(
            title,
            style: TextStyle(
              color: const Color.fromARGB(255, 41, 40, 40).withOpacity(0.8),
              fontSize: 22, // Slightly smaller font size
              fontWeight: FontWeight.bold, // Only the title is bold
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4), // Reduced spacing
          // Display the content in normal font
          Text(
            content,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14, // Normal font size
              fontWeight: FontWeight.normal, // Normal font weight
            ),
            maxLines: 2, // Show only 2 lines of content
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4), // Reduced spacing
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: onReadMore,
              child: Text('Read more', style: TextStyle(color: Colors.brown)),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------
// BLOG DETAIL PAGE (EDITABLE)
// ------------------------------------
class BlogDetailPage extends StatelessWidget {
  final String blogText;
  final int blogIndex;
  final Future<void> Function(int, String) onBlogEdited;

  const BlogDetailPage({
    Key? key,
    required this.blogText,
    required this.blogIndex,
    required this.onBlogEdited,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with increased height
      appBar: AppBar(
        backgroundColor: Colors.brown,
        toolbarHeight: 80.0,
        title: const Text(
          'My Blog',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white, // Title color changed to white
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Arrow color changed to white
        ),
        // Add "Edit" button
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigate to AddBlogPage in "edit" mode
              final updatedBlog = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddBlogPage(initialBlog: blogText),
                ),
              );
              // If user submitted changes, call callback and pop
              if (updatedBlog != null && updatedBlog.isNotEmpty) {
                await onBlogEdited(blogIndex, updatedBlog);
                Navigator.pop(context); // Return to the blog list
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(blogText, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

// ------------------------------------
// ADD BLOG PAGE
// (Used for both "Add" and "Edit" modes)
// ------------------------------------
class AddBlogPage extends StatefulWidget {
  final String? initialBlog;

  // Pass `initialBlog` when editing
  const AddBlogPage({Key? key, this.initialBlog}) : super(key: key);

  @override
  _AddBlogPageState createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialBlog ?? '', // If editing, set initial value
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text('Add Blog'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _controller,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Write your blog here...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: const Icon(Icons.save),
        onPressed: () {
          final blogText = _controller.text;
          if (blogText.isNotEmpty) {
            Navigator.pop(context, blogText); // Return the blog text
          }
        },
      ),
    );
  }
}
