// Authentication middleware
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { errorResponse } = require('../utils/response');

const auth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return errorResponse(res, 'Erişim token bulunamadı', 401);
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id);

    if (!user || !user.isActive) {
      return errorResponse(res, 'Kullanıcı bulunamadı', 401);
    }

    req.user = user;
    next();
  } catch (error) {
    return errorResponse(res, 'Geçersiz token', 401);
  }
};

module.exports = auth;