// Authentication routes (Giriş, Kayıt, Şifre Unuttum sayfaları için)
const express = require('express');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const User = require('../models/User');
const auth = require('../middleware/auth');
const {
  registerValidation,
  loginValidation,
  resetPasswordValidation,
  newPasswordValidation,
  handleValidationErrors
} = require('../middleware/validation');
const { successResponse, errorResponse } = require('../utils/response');

const router = express.Router();

// Token oluşturma
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE || '30d'
  });
};

// @desc    Kullanıcı kaydı
// @route   POST /api/auth/register
// @access  Public
router.post('/register', registerValidation, handleValidationErrors, async (req, res) => {
  try {
    const { name, username, email, password } = req.body;

    // Kullanıcı var mı kontrol et
    const existingUser = await User.findOne({
      $or: [{ email }, { username }]
    });

    if (existingUser) {
      return errorResponse(res, 'Bu e-posta veya kullanıcı adı zaten kullanılıyor', 400);
    }

    // Yeni kullanıcı oluştur
    const user = await User.create({
      name,
      username,
      email,
      password
    });

    const token = generateToken(user._id);

    successResponse(res, 'Kayıt başarılı', {
      user,
      token
    }, 201);

  } catch (error) {
    console.error('Register error:', error);
    errorResponse(res, 'Kayıt sırasında bir hata oluştu', 500);
  }
});

// @desc    Kullanıcı girişi
// @route   POST /api/auth/login
// @access  Public
router.post('/login', loginValidation, handleValidationErrors, async (req, res) => {
  try {
    const { email, password } = req.body;

    // Kullanıcıyı bul
    const user = await User.findOne({ email }).select('+password');

    if (!user || !user.isActive) {
      return errorResponse(res, 'Geçersiz e-posta veya şifre', 401);
    }

    // Şifre kontrol et
    const isMatch = await user.matchPassword(password);

    if (!isMatch) {
      return errorResponse(res, 'Geçersiz e-posta veya şifre', 401);
    }

    const token = generateToken(user._id);

    successResponse(res, 'Giriş başarılı', {
      user,
      token
    });

  } catch (error) {
    console.error('Login error:', error);
    errorResponse(res, 'Giriş sırasında bir hata oluştu', 500);
  }
});

// @desc    Şifre sıfırlama isteği
// @route   POST /api/auth/forgot-password
// @access  Public
router.post('/forgot-password', resetPasswordValidation, handleValidationErrors, async (req, res) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return errorResponse(res, 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı', 404);
    }

    // Reset token oluştur
    const resetToken = crypto.randomBytes(20).toString('hex');

    user.resetPasswordToken = crypto
      .createHash('sha256')
      .update(resetToken)
      .digest('hex');

    user.resetPasswordExpire = Date.now() + 10 * 60 * 1000; // 10 dakika

    await user.save();

    // Burada normalde e-posta gönderimi yapılır
    // Şimdilik sadece token'ı döndürüyoruz
    successResponse(res, 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi', {
      resetToken: resetToken // Gerçek uygulamada bu gönderilmez
    });

  } catch (error) {
    console.error('Forgot password error:', error);
    errorResponse(res, 'Şifre sıfırlama sırasında bir hata oluştu', 500);
  }
});

// @desc    Şifre sıfırlama
// @route   POST /api/auth/reset-password/:token
// @access  Public
router.post('/reset-password/:token', newPasswordValidation, handleValidationErrors, async (req, res) => {
  try {
    const { password } = req.body;

    // Token'ı hashle
    const resetPasswordToken = crypto
      .createHash('sha256')
      .update(req.params.token)
      .digest('hex');

    const user = await User.findOne({
      resetPasswordToken,
      resetPasswordExpire: { $gt: Date.now() }
    });

    if (!user) {
      return errorResponse(res, 'Geçersiz veya süresi dolmuş token', 400);
    }

    // Yeni şifreyi kaydet
    user.password = password;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;

    await user.save();

    const token = generateToken(user._id);

    successResponse(res, 'Şifre başarıyla güncellendi', {
      user,
      token
    });

  } catch (error) {
    console.error('Reset password error:', error);
    errorResponse(res, 'Şifre sıfırlama sırasında bir hata oluştu', 500);
  }
});

// @desc    Mevcut kullanıcı bilgilerini getir
// @route   GET /api/auth/me
// @access  Private
router.get('/me', auth, async (req, res) => {
  try {
    successResponse(res, 'Kullanıcı bilgileri', req.user);
  } catch (error) {
    console.error('Get me error:', error);
    errorResponse(res, 'Kullanıcı bilgileri alınırken hata oluştu', 500);
  }
});

// @desc    Çıkış yap
// @route   POST /api/auth/logout
// @access  Private
router.post('/logout', auth, async (req, res) => {
  try {
    // JWT token'lar stateless olduğu için sunucu tarafında logout işlemi yapmıyoruz
    // Client tarafında token'ı silmek yeterli
    successResponse(res, 'Başarıyla çıkış yapıldı');
  } catch (error) {
    console.error('Logout error:', error);
    errorResponse(res, 'Çıkış sırasında bir hata oluştu', 500);
  }
});

module.exports = router;