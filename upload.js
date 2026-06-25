// Sử dụng Vercel Blob để lưu file (Rất tiện lợi, không cần Google)
import { put } from '@vercel/blob';

export default async function handler(req, res) {
  if (req.method === 'POST') {
    const file = req.body; // File nhận được từ frontend
    const filename = req.headers['x-vercel-filename'];
    
    // Lưu file vào Blob Storage của chính Vercel
    const blob = await put(filename, file, {
      access: 'public',
    });

    return res.status(200).json({ url: blob.url });
  }
}
