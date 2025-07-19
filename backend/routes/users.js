// User routes (Profil, Profil Düzenle, Ayarlar sayfaları için)
const express = require('express');
const User = require('../models/User');
const auth = require('../middleware/auth');
const { updateProfileValidation, handleValidationErrors } = require('../middleware/validation');
const { successResponse, errorResponse } = require('../utils/response');

const router = express.Router();

// @desc    Profil bilgilerini getir
// @route   GET /api/users/profile
// @access  Private
router.get('/profile', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return errorResponse(res, 'Kullanıcı bulunamadı', 404);
    }

    successResponse(res, 'Profil bilgileri', user);
  } catch (error) {
    console.error('Get profile error:', error);
    errorResponse(res, 'Profil bilgileri alınırken hata oluştu', 500);
  }
});

// @desc    Profil bilgilerini güncelle
// @route   PUT /api/users/profile
// @access  Private
router.put('/profile', auth, updateProfileValidation, handleValidationErrors, async (req, res) => {
  try {
    const { name, username, email } = req.body;
    
    // Kullanıcıyı bul
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return errorResponse(res, 'Kullanıcı bulunamadı', 404);
    }

    // E-posta veya kullanıcı adı değiştiriliyorsa, mevcut olup olmadığını kontrol et
    if (email && email !== user.email) {
      const emailExists = await User.findOne({ email, _id: { $ne: user._id } });
      if (emailExists) {
        return errorResponse(res, 'Bu e-posta adresi zaten kullanılıyor', 400);
      }
    }

    if (username && username !== user.username) {
      const usernameExists = await User.findOne({ username, _id: { $ne: user._id } });
      if (usernameExists) {
        return errorResponse(res, 'Bu kullanıcı adı zaten kullanılıyor', 400);
      }
    }

    // Bilgileri güncelle
    if (name) user.name = name;
    if (username) user.username = username;
    if (email) user.email = email;

    await user.save();

    successResponse(res, 'Profil başarıyla güncellendi', user);
  } catch (error) {
    console.error('Update profile error:', error);
    errorResponse(res, 'Profil güncellenirken hata oluştu', 500);
  }
});

// @desc    Şifre güncelle
// @route   PUT /api/users/password
// @access  Private
router.put('/password', auth, async (req, res) => {
  try {
    const { currentPassword, newPassword, confirmPassword } = req.body;

    // Validasyon
    if (!currentPassword || !newPassword || !confirmPassword) {
      return errorResponse(res, 'Tüm alanlar gereklidir', 400);
    }

    if (newPassword !== confirmPassword) {
      return errorResponse(res, 'Yeni şifreler eşleşmiyor', 400);
    }

    if (newPassword.length < 6) {
      return errorResponse(res, 'Yeni şifre en az 6 karakter olmalıdır', 400);
    }

    // Kullanıcıyı bul
    const user = await User.findById(req.user.id).select('+password');

    if (!user) {
      return errorResponse(res, 'Kullanıcı bulunamadı', 404);
    }

    // Mevcut şifreyi kontrol et
    const isMatch = await user.matchPassword(currentPassword);

    if (!isMatch) {
      return errorResponse(res, 'Mevcut şifre yanlış', 400);
    }

    // Yeni şifreyi kaydet
    user.password = newPassword;
    await user.save();

    successResponse(res, 'Şifre başarıyla güncellendi');
  } catch (error) {
    console.error('Update password error:', error);
    errorResponse(res, 'Şifre güncellenirken hata oluştu', 500);
  }
});

// @desc    Kullanıcı ayarlarını getir
// @route   GET /api/users/settings
// @access  Private
router.get('/settings', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('preferences');
    
    if (!user) {
      return errorResponse(res, 'Kullanıcı bulunamadı', 404);
    }

    successResponse(res, 'Kullanıcı ayarları', user.preferences);
  } catch (error) {
    console.error('Get settings error:', error);
    errorResponse(res, 'Ayarlar alınırken hata oluştu', 500);
  }
});

// @desc    Kullanıcı ayarlarını güncelle
// @route   PUT /api/users/settings
// @access  Private
router.put('/settings', auth, async (req, res) => {
  try {
    const { notifications, darkMode } = req.body;
    
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return errorResponse(res, 'Kullanıcı bulunamadı', 404);
    }

    // Ayarları güncelle
    if (typeof notifications === 'boolean') {
      user.preferences.notifications = notifications;
    }
    
    if (typeof darkMode === 'boolean') {
      user.preferences.darkMode = darkMode;
    }

    await user.save();

    successResponse(res, 'Ayarlar başarıyla güncellendi', user.preferences);
  } catch (error) {
    console.error('Update settings error:', error);
    errorResponse(res, 'Ayarlar güncellenirken hata oluştu', 500);
  }
});

// @desc    Hesabı deaktif et
// @route   DELETE /api/users/account
// @access  Private
router.delete('/account', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return errorResponse(res, 'Kullanıcı bulunamadı', 404);
    }

    // Hesabı deaktif et (tamamen silmek yerine)
    user.isActive = false;
    await user.save();

    successResponse(res, 'Hesap başarıyla deaktif edildi');
  } catch (error) {
    console.error('Deactivate account error:', error);
    errorResponse(res, 'Hesap deaktif edilirken hata oluştu', 500);
  }
});

module.exports = router;