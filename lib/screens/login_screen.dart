import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/haptic_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onLogin});
  final VoidCallback? onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _slideTimer;
  
  String _role = 'CITIZEN';
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    _slideTimer = Timer(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _animationController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  String? _validateName(String? value) {
    if (!_isLogin && (value == null || value.trim().isEmpty)) {
      return 'Name is required';
    }
    
    if (!_isLogin && value!.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^[0-9+\-\s()]{10,}$');
      if (!phoneRegex.hasMatch(value.trim())) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }

  Future<void> _submit() async {
    print('🔍 Login form submitted');
    
    if (!_formKey.currentState!.validate()) {
      await HapticService.error();
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    await HapticService.buttonTap();

    try {
      print('🔍 Attempting login with: ${_emailController.text.trim()}');
      
      if (_isLogin) {
        final result = await ApiService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        print('✅ Login successful: $result');
        await HapticService.success();
      } else {
        print('🔍 Attempting registration...');
        await ApiService.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          number: _phoneController.text.trim().isEmpty 
              ? null 
              : _phoneController.text.trim(),
          role: _role,
        );
        
        await ApiService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        await HapticService.success();
      }

      if (mounted) {
        widget.onLogin?.call();
      }
    } on ApiException catch (e) {
      print('❌ ApiException: ${e.message}');
      await HapticService.error();
      setState(() {
        _error = e.message;
      });
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e');
      print('❌ Stack trace: $stackTrace');
      await HapticService.error();
      setState(() {
        _error = 'Unexpected error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleMode() async {
    await HapticService.selectionClick();
    setState(() {
      _isLogin = !_isLogin;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withOpacity(0.1),
              AppTheme.warning.withOpacity(0.1),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 768;
              final maxWidth = isTablet ? 500.0 : constraints.maxWidth * 0.9;
              
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildLoginCard(context, isTablet),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 40 : 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildFormFields(),
              if (_error != null) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(),
              ],
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 16),
              _buildToggleModeButton(),
              if (_isLogin) ...[
                const SizedBox(height: 20),
                _buildDemoCredentials(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.security_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Flood & Earthquake\nAlert System',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppTheme.slate800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin ? 'Welcome back! Sign in to continue' : 'Create your account to get started',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.slate500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        if (!_isLogin) ...[
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
            validator: _validateName,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number (Optional)',
            icon: Icons.phone_outlined,
            validator: _validatePhone,
            keyboardType: TextInputType.phone,
            hintText: '+1 (555) 123-4567',
          ),
          const SizedBox(height: 16),
        ],
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
          hintText: 'you@example.com',
        ),
        const SizedBox(height: 16),
        _buildPasswordField(),
        if (!_isLogin) ...[
          const SizedBox(height: 16),
          _buildRoleDropdown(),
        ],
        if (_isLogin) ...[
          const SizedBox(height: 12),
          _buildRememberMeCheckbox(),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppTheme.slate400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.error, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.slate50,
        labelStyle: TextStyle(color: AppTheme.slate600),
        hintStyle: TextStyle(color: AppTheme.slate400),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      validator: _validatePassword,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.slate400),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppTheme.slate400,
          ),
          onPressed: () async {
            await HapticService.lightImpact();
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.error, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.slate50,
        labelStyle: TextStyle(color: AppTheme.slate600),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Account Type',
        prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.slate400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.slate50,
        labelStyle: TextStyle(color: AppTheme.slate600),
      ),
      items: const [
        DropdownMenuItem(
          value: 'CITIZEN',
          child: Row(
            children: [
              Icon(Icons.person, size: 20),
              SizedBox(width: 8),
              Text('Citizen'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'NGO',
          child: Row(
            children: [
              Icon(Icons.business, size: 20),
              SizedBox(width: 8),
              Text('NGO (Organization)'),
            ],
          ),
        ),
      ],
      onChanged: (value) async {
        await HapticService.selectionClick();
        setState(() {
          _role = value ?? 'CITIZEN';
        });
      },
      validator: (value) => value == null ? 'Please select account type' : null,
    );
  }

  Widget _buildRememberMeCheckbox() {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Checkbox(
            value: _rememberMe,
            onChanged: (value) async {
              await HapticService.lightImpact();
              setState(() {
                _rememberMe = value ?? false;
              });
            },
            activeColor: AppTheme.primary,
          ),
          Text(
            'Remember me',
            style: TextStyle(
              color: AppTheme.slate600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () async {
                await HapticService.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Forgot password feature coming soon!'),
                  ),
                );
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: AppTheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isLoading ? null : _submit,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isLogin ? Icons.login_rounded : Icons.person_add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isLogin ? 'Sign In' : 'Create Account',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleModeButton() {
    return TextButton(
      onPressed: _toggleMode,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: AppTheme.slate600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: _isLogin
                  ? "Don't have an account? "
                  : 'Already have an account? ',
            ),
            TextSpan(
              text: _isLogin ? 'Sign Up' : 'Sign In',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCredentials() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Demo Credentials',
                style: TextStyle(
                  color: AppTheme.info,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Citizen: citizen@demo.com / demo123\nNGO: ngo@demo.com / demo123',
            style: TextStyle(
              color: AppTheme.slate600,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
