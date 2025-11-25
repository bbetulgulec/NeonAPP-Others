import 'package:flutter/material.dart';

class AnimationWidgetState extends StatefulWidget {
  const AnimationWidgetState({super.key});

  @override
  State<AnimationWidgetState> createState() => _AnimationWidgetStateState();
}

class _AnimationWidgetStateState extends State<AnimationWidgetState>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  late final AnimationController _rotateController;
  late final Animation<double> _rotateAnimation;

  late final AnimationController _textController;
  late final Animation<Offset> _textAnimation;

  bool isScaled = false;
  bool isRotated = false;
  bool isTextMoved = false;

  bool _isSelectedFOUR = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.fastOutSlowIn,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    _textController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _textAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, 0.2),
        ).animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void toggleScale() {
    if (isScaled) {
      _scaleController.reverse();
    } else {
      _scaleController.forward();
    }
    setState(() {
      isScaled = !isScaled;
    });
  }

  void toggleRotate() {
    if (isRotated) {
      _rotateController.reverse();
    } else {
      _rotateController.forward();
    }
    setState(() {
      isRotated = !isRotated;
    });
  }

  void toggleText() {
    if (isTextMoved) {
      _textController.reverse();
    } else {
      _textController.forward();
    }
    setState(() {
      isTextMoved = !isTextMoved;
    });
  }

  void toggleAnimatedSize() {
    setState(() {
      _isSelectedFOUR = !_isSelectedFOUR;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //ROTATE
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.network(
                        "https://st4.depositphotos.com/1763191/38960/v/950/depositphotos_389606898-stock-illustration-young-beautiful-witch-black-magic.jpg",
                        width: 100,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: MaterialButton(
                        color: Colors.purple,
                        onPressed: toggleScale,
                        child: Text(isScaled ? "Gizle" : "Göster"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              //TEXT
              SlideTransition(
                position: _textAnimation,
                child: Column(
                  children: [
                    const Text(
                      "Hareketli Text",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    MaterialButton(
                      color: Colors.orange,
                      onPressed: toggleText,
                      child: Text(isTextMoved ? "Yukarı Al" : "Aşağı İn"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              //ROTATE
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RotationTransition(
                      turns: _rotateAnimation,
                      child: Image.network(
                        "https://w7.pngwing.com/pngs/499/732/png-transparent-silver-and-brown-revolver-illustration-firearm-weapon-pistol-cartoon-revolver-s-ak47-handgun-rifle.png",
                        fit: BoxFit.contain,
                        height: 150,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: MaterialButton(
                        color: Colors.blue,
                        onPressed: toggleRotate,
                        child: const Text("180° Döndür"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // SİZE
              GestureDetector(
                onTap: toggleAnimatedSize,
                child: ColoredBox(
                  color: Colors.amberAccent,
                  child: AnimatedSize(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    child: SizedBox.square(
                      dimension: _isSelectedFOUR ? 250.0 : 100.0,
                      child: const Center(child: FlutterLogo(size: 75.0)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MaterialButton(
                color: Colors.green,
                onPressed: toggleAnimatedSize,
                child: Text(_isSelectedFOUR ? "Küçült" : "Büyüt"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
