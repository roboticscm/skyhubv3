export class Color {
  static hexToRGBA(hex, alpha) {
    let r = parseInt(hex.slice(1, 3), 16),
      g = parseInt(hex.slice(3, 5), 16),
      b = parseInt(hex.slice(5, 7), 16);

    if (alpha) {
      return 'rgba(' + r + ', ' + g + ', ' + b + ', ' + alpha + ')';
    } else {
      return 'rgb(' + r + ', ' + g + ', ' + b + ')';
    }
  }

  static changeAlphaOfRGBA(rgba, alpha) {
    return rgba.replace(/[^,]+(?=\))/, `${alpha}`);
  }

  static applyAlpha(colors, alpha) {
    const body = document.querySelector('body');
    colors.map((item) => {
      const key = Object.keys(item)[0];
      const value = item[key];
      let newColor = null;
      if (value.startsWith('#')) {
        newColor = Color.hexToRGBA(value, alpha);
      } else {
        newColor = Color.changeAlphaOfRGBA(value, alpha);
      }

      body.style.setProperty(key, newColor);
    });
  }
}

export const getThemeColors = () => {
  const body = document.querySelector('body');
  return [
    {
      ['--base-background']: getComputedStyle(body)
        .getPropertyValue('--base-background')
        .trim(),
    },
    {
      ['--base-color']: getComputedStyle(body)
        .getPropertyValue('--base-color')
        .trim(),
    },
    {
      ['--bg-primary']: getComputedStyle(body)
        .getPropertyValue('--bg-primary')
        .trim(),
    },
    {
      ['--primary']: getComputedStyle(body)
        .getPropertyValue('--primary')
        .trim(),
    },
    {
      ['--bg-secondary']: getComputedStyle(body)
        .getPropertyValue('--bg-secondary')
        .trim(),
    },
    {
      ['--bg-tertiary']: getComputedStyle(body)
        .getPropertyValue('--bg-tertiary')
        .trim(),
    },
    {
      ['--bg-gradient-from']: getComputedStyle(body)
        .getPropertyValue('--bg-gradient-from')
        .trim(),
    },
    {
      ['--bg-gradient-to']: getComputedStyle(body)
        .getPropertyValue('--bg-gradient-to')
        .trim(),
    },
    {
      ['--readonly-text-color']: getComputedStyle(body)
        .getPropertyValue('--readonly-text-color')
        .trim(),
    },
  ];
};
