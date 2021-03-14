export const resizeBase64Img = (base64, width, height) => {
  return new Promise((resolve, reject) => {
    const canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    const context = canvas.getContext('2d');
    const img = document.createElement('img');
    img.src = base64;
    img.onload = function () {
      context.scale(width / this.width, height / this.height);
      context.drawImage(this, 0, 0);
      resolve(canvas.toDataURL());
    };
  });
}

export const convertBlobToBytes = (blob) => {
  return new Promise(function (resolve) {
    const reader = new FileReader();

    reader.onloadend = function () {
      resolve(reader.result);
    };

    reader.readAsArrayBuffer(blob);
  });
}

export const base64ToUint8Array = (base64) => {
  const binaryString = window.atob(base64);
  const len = binaryString.length;
  const bytes = new Uint8Array(len);
  for (let i = 0; i < len; i++) {
      bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes;
}