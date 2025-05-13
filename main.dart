import 'package:flutter/material.dart';
import 'dart:async'; // Needed for PageView auto-scroll timer

// --- Data Simulation ---

// User Data (Simulated Database - LOST ON APP CLOSE)
List<Map<String, dynamic>> users = [ // Changed to Map<String, dynamic> to store address
  {'name': 'Test User', 'email': 'test@example.com', 'password': 'password123', 'address': null}, // Start with null address
];
Map<String, dynamic>? currentUser; // Holds logged-in user info ONLY during the session

// Food Items (Simulated Database - LOST ON APP CLOSE)
Map<String, List<FoodItem>> foodItems = {
  'Burgers': [
    FoodItem(id: 'b1', name: 'masala dosa', price: 5.99, imagePath: 'placeholder', category: 'Burgers'),
    FoodItem(id: 'b2', name: 'Cheese Burger', price: 6.99, imagePath: 'placeholder', category: 'Burgers'),
    FoodItem(id: 'b3', name: 'Chicken Burger', price: 7.49, imagePath: 'placeholder', category: 'Burgers'),
  ],
  'Pizza': [
    FoodItem(id: 'p1', name: 'Margherita Pizza', price: 8.50, imagePath: 'placeholder', category: 'Pizza'),
    FoodItem(id: 'p2', name: 'Pepperoni Pizza', price: 9.50, imagePath: 'placeholder', category: 'Pizza'),
    FoodItem(id: 'p3', name: 'Veggie Pizza', price: 9.00, imagePath: 'placeholder', category: 'Pizza'),
  ],
  'Drinks': [
    FoodItem(id: 'd1', name: 'Cola', price: 1.50, imagePath: 'placeholder', category: 'Drinks'),
    FoodItem(id: 'd2', name: 'Juice', price: 2.00, imagePath: 'placeholder', category: 'Drinks'),
    FoodItem(id: 'd3', name: 'Iced Tea', price: 1.75, imagePath: 'placeholder', category: 'Drinks'),
  ],
  'Sandwich': [
    FoodItem(id: 's1', name: 'Veg Sandwich', price: 3.50, imagePath: 'placeholder', category: 'Sandwich'),
    FoodItem(id: 's2', name: 'Chicken Sandwich', price: 4.50, imagePath: 'placeholder', category: 'Sandwich'),
    FoodItem(id: 's3', name: 'Club Sandwich', price: 5.00, imagePath: 'placeholder', category: 'Sandwich'),
  ],
  'Desserts': [
    FoodItem(id: 'ds1', name: 'Brownie', price: 2.50, imagePath: 'placeholder', category: 'Desserts'),
    FoodItem(id: 'ds2', name: 'Ice Cream', price: 2.00, imagePath: 'placeholder', category: 'Desserts'),
  ]
};

// Recommendations (subset of foodItems or different list)
List<FoodItem> recommendations = [
  foodItems['Burgers']![1], // Cheese Burger
  foodItems['Pizza']![0],   // Margherita
  foodItems['Sandwich']![2],// Club Sandwich
  foodItems['Drinks']![1],   // Juice
];

// Cart Items (Global State - simplified, LOST ON APP CLOSE)
List<CartItem> cartItems = [];

// Order History (Simulated - LOST ON APP CLOSE)
List<Order> orderHistory = [];

// Help Queries (Simulated Database - LOST ON APP CLOSE)
List<Map<String, String>> helpQueries = [];

// --- Models ---

class FoodItem {
  final String id;
  final String name;
  final double price;
  final String imagePath; // NOTE: Not used to load images in this version
  final String category;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.category,
  });
}

class CartItem {
  final FoodItem foodItem;
  int quantity;

  CartItem({required this.foodItem, this.quantity = 1});
}

class Order {
  final String orderId;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final String deliveryAddress; // Address used for THIS order

  Order({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.deliveryAddress,
  });
}

// --- Global Helper Functions ---

int getCartItemCount() {
  // Safely calculate count
  try {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  } catch (e) {
    print("Error calculating cart count: $e");
    return 0; // Return 0 in case of error
  }
}

// --- Main Application ---

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafeteria App (Basic)',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              // Define default button styles here if needed
            )
        ),
        // Ensure input fields don't have excessive padding causing overflow issues
        inputDecorationTheme: const InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0), // Standard padding
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const GetStartedPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
        '/cart': (context) => const CartPage(),
        '/checkout': (context) => const CheckoutPage(),
        '/profile_edit': (context) => const ProfileEditPage(),
        '/manage_address': (context) => const ManageAddressPage(), // Route for address page
        '/help': (context) => const HelpPage(),
        '/order_history': (context) => const OrderHistoryPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/category') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null && args.containsKey('categoryName')) {
            VoidCallback? updateCallback;
            if (args.containsKey('onCartUpdated')) {
              try {
                updateCallback = args['onCartUpdated'] as VoidCallback;
              } catch (e) {
                print("Error casting onCartUpdated callback: $e");
                updateCallback = () {};
              }
            }
            return MaterialPageRoute(
              builder: (context) => CategoryPage(
                categoryName: args['categoryName'],
                onCartUpdated: updateCallback,
              ),
            );
          }
          return MaterialPageRoute(builder: (context) => const HomePage()); // Fallback
        }
        return null;
      },
    );
  }
}

// --- Page Widgets ---

// 1. Get Started Page
class GetStartedPage extends StatelessWidget {
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.food_bank, size: 100, color: Colors.white),
              const SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (!mounted) return;
    setState(() {
      _errorMessage = null;
    });

    // --- Simulated Database Check ---
    var foundUserIndex = users.indexWhere( // Get index to modify address if needed later
            (user) => user['email'] == email && user['password'] == password);

    if (foundUserIndex != -1) {
      // --- Login Success (Session Only) ---
      currentUser = users[foundUserIndex]; // Store current user info for this session
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = 'Invalid email or password.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade800, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Login',
                  style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [ Shadow(blurRadius: 5.0, color: Colors.black54, offset: Offset(2, 2)) ]
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.5),
                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _errorMessage != null ? '' : null,
                    errorStyle: const TextStyle(height: 0),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.5),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _errorMessage != null ? '' : null,
                    errorStyle: const TextStyle(height: 0),
                  ),
                ),
                const SizedBox(height: 5),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Forgot Password clicked (Not Implemented)')),
                        );
                      }
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  onPressed: _login,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", style: TextStyle(color: Colors.white)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 3. Sign Up Page
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (!mounted) return;

    setState(() {
      _errorMessage = null;
    });

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'All fields are required.');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }
    if (users.any((user) => user['email'] == email)) {
      setState(() => _errorMessage = 'Email already exists.');
      return;
    }

    // --- Simulated Database Save ---
    final newUser = {'name': name, 'email': email, 'password': password, 'address': null}; // Include null address
    users.add(newUser);
    print('User Signed Up: $newUser');
    print('Current Users: $users');

    // --- Auto-Login after Sign Up (Session Only) ---
    currentUser = newUser;
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.cyan.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Create Account',
                  style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [ Shadow(blurRadius: 5.0, color: Colors.black54, offset: Offset(2, 2)) ]
                  ),
                ),
                const SizedBox(height: 30),
                // Use helper - maxLines: 1 is default, should prevent overflow
                _buildTextField(_nameController, 'Name', Icons.person),
                const SizedBox(height: 15),
                _buildTextField(_emailController, 'Email', Icons.email, TextInputType.emailAddress),
                const SizedBox(height: 15),
                _buildTextField(_passwordController, 'Password', Icons.lock, null, true),
                const SizedBox(height: 15),
                _buildTextField(_confirmPasswordController, 'Confirm Password', Icons.lock_outline, null, true),
                const SizedBox(height: 10),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  onPressed: _signUp,
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?", style: TextStyle(color: Colors.white)),
                    TextButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for text fields on Sign Up page
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, [TextInputType? keyboardType, bool isPassword = false]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      // maxLines: 1, // This is the default, explicitly adding it doesn't hurt
      style: const TextStyle(color: Colors.black), // Input text color
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        prefixIcon: Icon(icon, color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        // contentPadding is already set globally via theme, but can override here if needed
      ),
    );
  }
}

// 4. Home Page (Stateful to handle BottomNav and Cart updates)
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _updateCartBadge() {
    if (mounted) {
      setState(() {});
    }
  }

  // No need for the _slideshowTimer here as it's handled within HomeContent

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(onCartUpdated: _updateCartBadge),
      CartPage(onCartUpdated: _updateCartBadge), // Pass callback for badge updates
      const ProfileContent(), // Profile now handles address internally
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (mounted) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}

// --- Content Widgets for HomePage Body ---

class HomeContent extends StatefulWidget {
  final VoidCallback onCartUpdated;

  const HomeContent({Key? key, required this.onCartUpdated}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  Timer? _pageViewTimer;

  @override
  void initState() {
    super.initState();
    _startPageViewTimer();
  }

  void _startPageViewTimer() {
    _pageViewTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_pageController.hasClients) {
        int nextPage = 0;
        int currentPage = _pageController.page?.round() ?? 0;
        int pageCount = 3; // Assuming 3 pages

        if (currentPage < pageCount - 1) {
          nextPage = currentPage + 1;
        } // else nextPage remains 0 (loops back)

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        ).catchError((e) {
          print("Error animating PageView: $e");
        });
      }
    });
  }


  void _addToCart(FoodItem item) {
    if (!mounted) return;
    setState(() {
      var existingItemIndex = cartItems.indexWhere((cartItem) => cartItem.foodItem.id == item.id);
      if (existingItemIndex != -1) {
        cartItems[existingItemIndex].quantity++;
      } else {
        cartItems.add(CartItem(foodItem: item, quantity: 1));
      }
      widget.onCartUpdated();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} added to cart'), duration: const Duration(seconds: 1)),
    );
  }

  void _increaseQuantity(String itemId) {
    if (!mounted) return;
    setState(() {
      var itemIndex = cartItems.indexWhere((cartItem) => cartItem.foodItem.id == itemId);
      if(itemIndex != -1) {
        cartItems[itemIndex].quantity++;
        widget.onCartUpdated();
      }
    });
  }

  void _decreaseQuantity(String itemId) {
    if (!mounted) return;
    setState(() {
      var itemIndex = cartItems.indexWhere((cartItem) => cartItem.foodItem.id == itemId);
      if(itemIndex != -1) {
        if(cartItems[itemIndex].quantity > 1) {
          cartItems[itemIndex].quantity--;
        } else {
          cartItems.removeAt(itemIndex);
        }
        widget.onCartUpdated();
      }
    });
  }

  int _getQuantityInCart(String itemId) {
    var itemIndex = cartItems.indexWhere((cartItem) => cartItem.foodItem.id == itemId);
    return itemIndex != -1 ? cartItems[itemIndex].quantity : 0;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageViewTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> sliderPages = [
      Container(color: Colors.red.shade100, child: const Center(child: Text("Special Offer!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))),
      Container(color: Colors.green.shade100, child: const Center(child: Text("New Items Added!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))),
      Container(color: Colors.blue.shade100, child: const Center(child: Text("Combo Deals!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orangeAccent, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Hi, ${currentUser?['name'] ?? 'Guest'}!', style: const TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for food...',
                    hintStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 180,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: sliderPages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: sliderPages[index],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Text(
                  "What's your mood?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                padding: const EdgeInsets.only(left: 16.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: foodItems.keys.length,
                  itemBuilder: (context, index) {
                    String categoryName = foodItems.keys.elementAt(index);
                    IconData categoryIcon = Icons.fastfood;
                    switch (categoryName) {
                      case 'Pizza': categoryIcon = Icons.local_pizza; break;
                      case 'Burgers': categoryIcon = Icons.lunch_dining; break;
                      case 'Drinks': categoryIcon = Icons.local_drink; break;
                      case 'Sandwich': categoryIcon = Icons.bakery_dining; break;
                      case 'Desserts': categoryIcon = Icons.cake; break;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: GestureDetector(
                        onTap: () {
                          if (mounted) {
                            Navigator.pushNamed(
                              context,
                              '/category',
                              arguments: {
                                'categoryName': categoryName,
                                'onCartUpdated': widget.onCartUpdated,
                              },
                            );
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white.withOpacity(0.8),
                              child: Icon(categoryIcon, size: 30, color: Colors.deepOrange),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              categoryName,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Text(
                  "Recommendations",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index >= recommendations.length) return null; // Bounds check
                    final item = recommendations[index];
                    final quantityInCart = _getQuantityInCart(item.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, color: Colors.orange)),
                                ],
                              ),
                            ),
                            if (quantityInCart == 0)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(8)
                                ),
                                onPressed: () => _addToCart(item),
                                child: const Icon(Icons.add),
                              )
                            else
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                    onPressed: () => _decreaseQuantity(item.id),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Text(
                                        quantityInCart.toString(),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                    onPressed: () => _increaseQuantity(item.id),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: recommendations.length, // Use actual length
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

// --- Profile Content Widget ---
class ProfileContent extends StatefulWidget {
  const ProfileContent({Key? key}) : super(key: key);

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {

  void _logout() {
    currentUser = null;
    cartItems.clear();
    if(mounted) {
      // Update the state to reflect logout in the profile view itself
      setState(() {});
      // Navigate after state update (optional, could just stay on profile tab showing logged out state)
      // If you always want to go to login screen:
      // Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
    }
  }

  // Function to refresh the address display after returning from ManageAddressPage
  void _refreshAddress() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current address for display
    String displayAddress = currentUser?['address'] ?? 'Add your address';

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (currentUser != null) ...[
          // --- Logged In View ---
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.orangeAccent,
            child: Text(
              currentUser!['name']![0].toUpperCase(),
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            currentUser!['name']!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            currentUser!['email']!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
        ] else ... [
          // --- Logged Out View ---
          // ... (same as before)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0),
              child: Text("Please log in to view your profile.", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text("Login / Sign Up"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
        ],

        // --- Profile Options ---
        _buildProfileOption(
          context,
          icon: Icons.edit,
          title: 'Edit Personal Details',
          subtitle: 'Name, Email, Password',
          onTap: () {
            if (currentUser == null) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please log in to edit profile")));
              }
              return;
            }
            if (mounted) {
              Navigator.pushNamed(context, '/profile_edit');
            }
          },
        ),
        // --- Manage Address Option ---
        _buildProfileOption(
          context,
          icon: Icons.location_on,
          title: 'Manage Address',
          subtitle: displayAddress, // Show current address or prompt
          onTap: () {
            if (currentUser == null) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please log in to manage address")));
              }
              return;
            }
            if (mounted) {
              // Navigate and then refresh state when returning
              Navigator.pushNamed(context, '/manage_address').then((_) => _refreshAddress());
            }
          },
        ),
        _buildProfileOption(
          context,
          icon: Icons.history,
          title: 'Order History',
          subtitle: 'View your past orders',
          onTap: () {
            if (mounted) {
              Navigator.pushNamed(context, '/order_history');
            }
          },
        ),
        _buildProfileOption(
          context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'FAQs and Contact Us',
          onTap: () {
            if (mounted) {
              Navigator.pushNamed(context, '/help');
            }
          },
        ),

        const SizedBox(height: 30),
        if (currentUser != null)
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileOption(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis,), // Show address or prompt
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

// 5. Category Page
class CategoryPage extends StatefulWidget {
  final String categoryName;
  final VoidCallback? onCartUpdated;

  const CategoryPage({
    Key? key,
    required this.categoryName,
    this.onCartUpdated,
  }) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

  void _addToCart(FoodItem item) {
    if (!mounted) return;
    setState(() {
      var existingItemIndex = cartItems.indexWhere((cartItem) => cartItem.foodItem.id == item.id);
      if (existingItemIndex != -1) {
        cartItems[existingItemIndex].quantity++;
      } else {
        cartItems.add(CartItem(foodItem: item, quantity: 1));
      }
      widget.onCartUpdated?.call();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} added to cart'), duration: const Duration(seconds: 1)),
    );
  }

  void _increaseQuantity(String itemId) {
    if (!mounted) return;
    setState(() {
      var itemIndex = cartItems.indexWhere((cartItem) => cartItem.foodItem.id == itemId);
      if(itemIndex != -1) {
        cartItems[itemIndex].quantity++;
        widget.onCartUpdated?.call();
      }
    });
  }

  void _decreaseQuantity(String itemId) {
    if (!mounted) return;
    setState(() {
      var itemIndex = cartItems.indexWhere((cartItem) => cartItem.foodItem.id == itemId);
      if(itemIndex != -1) {
        if(cartItems[itemIndex].quantity > 1) {
          cartItems[itemIndex].quantity--;
        } else {
          cartItems.removeAt(itemIndex);
        }
        widget.onCartUpdated?.call();
      }
    });
  }

  int _getQuantityInCart(String itemId) {
    var itemIndex = cartItems.indexWhere((cartItem) => cartItem.foodItem.id == itemId);
    return itemIndex != -1 ? cartItems[itemIndex].quantity : 0;
  }

  @override
  Widget build(BuildContext context) {
    final List<FoodItem> itemsInCategory = foodItems[widget.categoryName] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName, style: const TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade200, Colors.orange.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Ensure back button is visible
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              color: Colors.white.withOpacity(0.5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: foodItems.keys.length,
                itemBuilder: (context, index) {
                  String category = foodItems.keys.elementAt(index);
                  bool isSelected = category == widget.categoryName;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if(selected && !isSelected && mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            '/category',
                            arguments: {
                              'categoryName': category,
                              'onCartUpdated': widget.onCartUpdated,
                            },
                          );
                        }
                      },
                      selectedColor: Colors.orange,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      backgroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: itemsInCategory.isEmpty
                  ? Center(child: Text('No items available in ${widget.categoryName}.', style: TextStyle(color: Colors.grey.shade700)))
                  : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: itemsInCategory.length,
                itemBuilder: (context, index) {
                  final item = itemsInCategory[index];
                  final quantityInCart = _getQuantityInCart(item.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 70, height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Icon(Icons.restaurant_menu, size: 45, color: Colors.grey),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, color: Colors.deepOrange, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const Spacer(flex: 1),
                          if (quantityInCart == 0)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold)
                              ),
                              onPressed: () => _addToCart(item),
                              child: const Text('ADD'),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: Colors.red, size: 20),
                                    onPressed: () => _decreaseQuantity(item.id),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Text(
                                        quantityInCart.toString(),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.green, size: 20),
                                    onPressed: () => _increaseQuantity(item.id),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (cartItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    if (mounted) {
                      Navigator.pushNamed(context, '/cart');
                    }
                  },
                  child: Text('Proceed to Checkout (${getCartItemCount()} items)'),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (!mounted) return;
          if (index == 0) Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          if (index == 1) Navigator.pushNamed(context, '/cart');
          if (index == 2) {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        },
      ),
    );
  }
}

// 6. Cart Page
class CartPage extends StatefulWidget {
  final VoidCallback? onCartUpdated;

  const CartPage({Key? key, this.onCartUpdated}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? deliveryAddress; // Make address nullable initially
  String estimatedDeliveryTime = '20-30 minutes';
  bool get isAddressAvailable => deliveryAddress != null && deliveryAddress!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _updateDeliveryAddress(); // Get initial address when page loads
  }

  // Function to get the current address from currentUser
  void _updateDeliveryAddress() {
    setState(() {
      deliveryAddress = currentUser?['address'];
    });
  }


  double get totalAmount {
    try {
      return cartItems.fold(0.0, (sum, item) => sum + (item.foodItem.price * item.quantity));
    } catch (e) {
      print("Error calculating total amount: $e");
      return 0.0;
    }
  }

  void _increaseQuantity(String itemId) {
    if (!mounted) return;
    setState(() {
      var itemIndex = cartItems.indexWhere((cartItem) => cartItem.foodItem.id == itemId);
      if(itemIndex != -1) {
        cartItems[itemIndex].quantity++;
        widget.onCartUpdated?.call();
      }
    });
  }

  void _decreaseQuantity(String itemId) {
    if (!mounted) return;
    setState(() {
      var itemIndex = cartItems.indexWhere((cartItem) => cartItem.foodItem.id == itemId);
      if(itemIndex != -1) {
        if(cartItems[itemIndex].quantity > 1) {
          cartItems[itemIndex].quantity--;
        } else {
          cartItems.removeAt(itemIndex);
        }
        widget.onCartUpdated?.call();
      }
    });
  }

  void _placeOrder() {
    // Ensure address is available before placing order
    if (!isAddressAvailable || cartItems.isEmpty || !mounted) return;

    final order = Order(
      orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      items: List.from(cartItems),
      totalAmount: totalAmount,
      orderDate: DateTime.now(),
      deliveryAddress: deliveryAddress!, // Use ! as we checked isAddressAvailable
    );
    orderHistory.add(order);
    print('Order Placed: ${order.orderId}');

    setState(() {
      cartItems.clear();
      widget.onCartUpdated?.call();
    });

    Navigator.pushReplacementNamed(
      context,
      '/checkout',
      arguments: {'estimatedTime': estimatedDeliveryTime},
    );
  }

  // Function to navigate to address page and update after returning
  void _goToManageAddress() {
    if (mounted) {
      Navigator.pushNamed(context, '/manage_address').then((_) {
        // This code runs when ManageAddressPage is popped
        _updateDeliveryAddress(); // Refresh the address in CartPage state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPartOfHomePage = widget.onCartUpdated != null;

    return Scaffold(
      appBar: !isPartOfHomePage ? AppBar(
        title: const Text('Your Cart', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orangeAccent, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ) : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // --- Delivery Address Section ---
                  _buildSectionTitle('Delivery Address'),
                  if (isAddressAvailable) ...[
                    Text(deliveryAddress!, style: const TextStyle(color: Colors.black87)),
                    TextButton(onPressed: _goToManageAddress, child: const Text('Change')),
                  ] else ...[
                    // Prompt to add address
                    Card(
                      color: Colors.yellow.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                            const SizedBox(width: 10),
                            const Expanded(child: Text('Please add a delivery address.')),
                            TextButton(
                              onPressed: _goToManageAddress,
                              child: const Text('ADD'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 15),
                  // --- End Delivery Address Section ---

                  _buildSectionTitle('Estimated Delivery'),
                  Text(estimatedDeliveryTime, style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Item Summary'),
                  if (cartItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0),
                      child: Center(child: Text('Your cart is empty.', style: TextStyle(fontSize: 18, color: Colors.black54))),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartItems[index];
                        final item = cartItem.foodItem;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: const Icon(Icons.shopping_basket, size: 30, color: Colors.grey),
                            ),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orange)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                                  onPressed: () => _decreaseQuantity(item.id),
                                  constraints: const BoxConstraints(), padding: EdgeInsets.zero,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Text(cartItem.quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 22),
                                  onPressed: () => _increaseQuantity(item.id),
                                  constraints: const BoxConstraints(), padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                  if (cartItems.isNotEmpty) ...[
                    _buildSectionTitle('Total Amount'),
                    Text(
                      '\$${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                      textAlign: TextAlign.right,
                    ),
                  ]
                ],
              ),
            ),

            // Place Order Button - Enabled only if items and address exist
            if (cartItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAddressAvailable ? Colors.black : Colors.grey, // Disabled color
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Disable button if address is missing
                  onPressed: isAddressAvailable ? _placeOrder : null,
                  child: const Text('Place Order'),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: !isPartOfHomePage ? AppBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (!mounted) return;
          if (index == 0) Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          if (index == 2) {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        },
      ) : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }
}

// 7. Checkout/Success Page
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final estimatedTime = args?['estimatedTime'] ?? '20-30 minutes';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 120,
              ),
              const SizedBox(height: 30),
              const Text(
                'Order Placed Successfully!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                'Estimated Delivery Time:',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              Text(
                estimatedTime,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
                },
                child: const Text('Back to Home', style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          if (index == 1) Navigator.pushNamed(context, '/cart');
          if (index == 2) {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        },
      ),
    );
  }
}

// 8. Profile Edit Page
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = currentUser?['name'] ?? '';
    _emailController.text = currentUser?['email'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();

    if (newName.isEmpty || newEmail.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Name and Email cannot be empty.'))
        );
      }
      return;
    }

    if (!mounted || currentUser == null) return;

    int userIndex = users.indexWhere((user) => user['email'] == currentUser!['email']);

    if(userIndex != -1) {
      // --- Simulate Update ---
      users[userIndex]['name'] = newName;
      users[userIndex]['email'] = newEmail;
      currentUser = users[userIndex]; // Update global current user object

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'))
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating profile. User not found.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            const Text('Change Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Current Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm New Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Change Password clicked (Not Implemented)')),
                  );
                }
              },
              child: const Text('Update Password'),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 16)
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

// 9. Manage Address Page (NEW)
class ManageAddressPage extends StatefulWidget {
  const ManageAddressPage({Key? key}) : super(key: key);

  @override
  State<ManageAddressPage> createState() => _ManageAddressPageState();
}

class _ManageAddressPageState extends State<ManageAddressPage> {
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load current address if it exists
    _addressController.text = currentUser?['address'] ?? '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    final newAddress = _addressController.text.trim();

    if (newAddress.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address cannot be empty.'))
        );
      }
      return;
    }

    if (!mounted || currentUser == null) return; // Need to be logged in

    // --- Simulate Update ---
    // Find user index to update the main users list (though currentUser is the primary one used)
    int userIndex = users.indexWhere((user) => user['email'] == currentUser!['email']);
    if (userIndex != -1) {
      users[userIndex]['address'] = newAddress; // Update in the main list as well
    }
    currentUser!['address'] = newAddress; // Update the current session user

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved successfully!'))
      );
      Navigator.pop(context); // Go back to the previous screen (Profile or Cart)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Delivery Address'),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              maxLines: 3, // Allow multi-line address input
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                hintText: 'Enter your full address (Street, City, Postal Code)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveAddress,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 16)
              ),
              child: const Text('Save Address'),
            ),
          ],
        ),
      ),
    );
  }
}


// Order History Page
class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayedHistory = List<Order>.from(orderHistory);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: displayedHistory.isEmpty
          ? const Center(child: Text('You have no past orders in this session.', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: displayedHistory.length,
        itemBuilder: (context, index) {
          final order = displayedHistory[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 15.0),
            child: ExpansionTile(
              title: Text('Order #${order.orderId.substring(order.orderId.length - 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Placed on: ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year} - Total: \$${order.totalAmount.toStringAsFixed(2)}'),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                ...(order.items).map((cartItem) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 2.0, bottom: 2.0),
                  child: Text(
                      '- ${cartItem.quantity} x ${cartItem.foodItem.name} (\$${(cartItem.foodItem.price * cartItem.quantity).toStringAsFixed(2)})'
                  ),
                )).toList(),
                const SizedBox(height: 10),
                const Text('Delivery Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(order.deliveryAddress),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Help Page
class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _questionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _submitQuery() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final question = _questionController.text.trim();

    if (name.isEmpty || email.isEmpty || question.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill in all fields.'))
        );
      }
      return;
    }
    if (!mounted) return;

    final query = {'name': name, 'email': email, 'question': question, 'timestamp': DateTime.now().toIso8601String()};
    helpQueries.add(query);
    print('Help Query Submitted (Session Only): $query');

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your query has been submitted.'))
    );

    _nameController.clear();
    _emailController.clear();
    _questionController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions (FAQs)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildFaqItem('How do I place an order?', 'Add items to cart, go to the Cart page, ensure your delivery address is added/correct, then tap "Place Order".'),
            _buildFaqItem('How do I change my delivery address?', 'Go to the Profile tab and tap "Manage Address". You can also add an address from the Cart page if it\'s missing.'),
            _buildFaqItem('Is my login saved?', 'No, in this version, you need to log in each time you open the app.'),
            _buildFaqItem('Can I see food pictures?', 'No, this version uses placeholder icons.'),
            _buildFaqItem('What payment methods are accepted?', 'This version simulates order placement without actual payment.'),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            const Text(
              'Still Need Help? Contact Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Your Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Your Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _questionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Your Question/Concern', border: OutlineInputBorder(), alignLabelWithHint: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitQuery,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 16)
              ),
              child: const Text('Submit Query'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        Text(answer, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }
}

// --- Common Widgets ---

// 8. Custom Bottom Navigation Bar
class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int cartCount = getCartItemCount();

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.orangeAccent,
      unselectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart),
              if (cartCount > 0)
                Positioned(
                  right: -8,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.white, width: 0.5)
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Cart',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}