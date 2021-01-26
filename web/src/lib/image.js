export function resizeBase64Img(base64, width, height) {
  return new Promise((resolve, reject) => {
    const canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    const context = canvas.getContext('2d');
    const img = document.createElement('img');
    img.src = base64;
    img.onload = function() {
      context.scale(width / this.width, height / this.height);
      context.drawImage(this, 0, 0);
      resolve(canvas.toDataURL());
    };
  });
}
