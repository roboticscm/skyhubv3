import { Window } from 'src/lib/window';
import { SettingsStore } from 'src/store/settings';

export const dragElement = (elmnt) => {
  let pos1 = 0,
    pos2 = 0,
    pos3 = 0,
    pos4 = 0;
  const dragMouseDown = (e) => {
    e = e || window.event;
    e.preventDefault();
    // get the mouse cursor position at startup:
    pos3 = e.clientX;
    pos4 = e.clientY;
    document.onmouseup = closeDragElement;
    // call a function whenever the cursor moves:
    document.onmousemove = elementDrag;
  };
  if (document.getElementById(elmnt.id + 'header')) {
    /* if present, the header is where you move the DIV from:*/
    document.getElementById(elmnt.id + 'header').onmousedown = dragMouseDown;
  } else {
    /* otherwise, move the DIV from anywhere inside the DIV:*/
    elmnt.onmousedown = dragMouseDown;
  }

  const elementDrag = (e) => {
    e = e || window.event;
    e.preventDefault();
    // calculate the new cursor position:
    pos1 = pos3 - e.clientX;
    pos2 = pos4 - e.clientY;
    pos3 = e.clientX;
    pos4 = e.clientY;
    // set the element's new position:
    elmnt.style.top = elmnt.offsetTop - pos2 + 'px';
    elmnt.style.left = elmnt.offsetLeft - pos1 + 'px';
  };

  const closeDragElement = () => {
    /* stop moving when mouse button is released:*/
    document.onmouseup = null;
    document.onmousemove = null;
  };
};

export const createModal = (menuPath, widthInPixel = null, heightInPixel = null) => {
  const state = {
    width: '',
    height: '',
    left: '',
    top: '',
    content: '',
    resolve: () => {},
  };

  const closeModal = (modalWrapperRef, action) => {
    if (state.resolve) {
      modalWrapperRef && modalWrapperRef.classList.remove('show-modal');
      state.resolve(action);
    }
  };

  const saveSettings = (modalId, keys, values) => {
    SettingsStore.saveUserSettings({
      menuPath,
      elementId: modalId,
      keys,
      values,
    });
  };

  const saveModalState = (modalRef) => {
    const isSmartPhone = window.isSmartPhone;
    if (isSmartPhone) {
      return;
    }

    if (
      !modalRef.style.left ||
      modalRef.style.left.includes('-') ||
      +modalRef.style.left.replace('px', '') + +modalRef.style.width.replace('px', '') > window.innerWidth
    ) {
      state.left = '0';
    } else {
      state.left = modalRef.style.left;
    }

    if (
      !modalRef.style.top ||
      modalRef.style.top.includes('-') ||
      +modalRef.style.top.replace('px', '') + +modalRef.style.top.replace('px', '') > window.innerHeight
    ) {
      state.top = '0';
    } else {
      state.top = modalRef.style.top;
    }

    state.width = modalRef.style.width;
    state.height = modalRef.style.height;

    saveSettings(modalRef.id, ['left', 'top', 'width', 'height'], [state.left, state.top, state.width, state.height]);
  };

  const loadSettings = (modalRef) => {
    const isSmartPhone = window.isSmartPhone;

    if (isSmartPhone) {
      const sw = screen.width;
      const sh = screen.height;
      const width = sw * 0.8;
      const height = sh * 0.6;

      const left = (sw * 0.2) / 2;
      const top = sh * 0.1;

      modalRef.style.width = `${width}px`;
      modalRef.style.height = `${height}px`;
      modalRef.style.left = `${left}px`;
      modalRef.style.top = `${top}px`;
      return;
    }

    SettingsStore.getUserSettings({ elementId: modalRef.id, menuPath })
      .then((r) => {
        const res = r.data;

        if (res && res.length >= 4) {
          if (modalRef) {
            res.map((it) => {
              modalRef.style[it.key] = it.value;
            });
          }
        } else {
          // default value for first times
          const _widthInPixel = widthInPixel ? widthInPixel : 500;
          const _heightInPixel = heightInPixel ? heightInPixel : 200;

          const pos = Window.getCenterWindowPosition(widthInPixel, heightInPixel);

          if (modalRef) {
            modalRef.style.width = `${_widthInPixel}px`;
            modalRef.style.height = `${_heightInPixel}px`;
            modalRef.style.left = `${pos.left}px`;
            modalRef.style.top = `${pos.top}px`;
          }
        }

        const sw = window.innerWidth;
        const sh = window.innerHeight;
        let outOfSize = false;
        if (+modalRef.style.width.replace('px', '') >= sw) {
          modalRef.style.width = `${sw * 0.8}px`;
          outOfSize = true;
        }

        if (+modalRef.style.height.replace('px', '') >= sh) {
          modalRef.style.height = `${sh * 0.8}px`;
          outOfSize = true;
        }

        if (outOfSize) {
          const left = (sw * 0.2) / 2;
          const top = sh * 0.1;
          modalRef.style.left = `${left}px`;
          modalRef.style.top = `${top}px`;
        }

        state.width = modalRef.style.width;
        state.height = modalRef.style.height;
        state.top = modalRef.style.top;
        state.left = modalRef.style.left;
      })
      .catch((error) => {
        console.error(error);
      });
  };

  return {
    state,
    closeModal,
    dragElement,
    saveModalState,
    loadSettings,
  };
};
