export class Dropdown {
  static show(id) {
    const ele = document.querySelector(`#${id}`);
    ele && ele.classList.add('show-dropdown');
  }

  static hide(id) {
    const ele = document.querySelector(`#${id}`);
    ele && ele.classList.remove('show-dropdown');
  }
}
