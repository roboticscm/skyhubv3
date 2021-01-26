export class Window {
  static getCenterWindowPosition(width, height) {
    const left = (window.innerWidth - width) / 2;
    const top = (window.innerHeight - height) / 2;
    return {
      left: left,
      top: top,
    };
  }
}
