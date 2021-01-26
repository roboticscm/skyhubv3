export const themes = [
  {
    key: 'ivory',
    theme: 'Ivory',
    preview: '#FFFAF6',
  },
  // {
  //   key: 'theme-green',
  //   theme: T('SYS.COLOR.GREEN'),
  //   preview: '#1b5e20',
  // },
  // {
  //   key: 'theme-blue',
  //   theme: T('SYS.COLOR.BLUE'),
  //   preview: '#0000FF',
  // },
  // {
  //   key: 'theme-pink',
  //   theme: T('SYS.COLOR.PINK'),
  //   preview: '#880e4f',
  // },
  // {
  //   key: 'theme-brown',
  //   theme: T('SYS.COLOR.BROWN'),
  //   preview: '#3e2723',
  // },
  {
    key: 'ebony',
    theme: 'Ebony',
    preview: '#161616',
  },
  // {
  //   key: 'theme-purple',
  //   theme: T('SYS.COLOR.PURPLE'),
  //   preview: '#6a1b9a',
  // },
  // {
  //   key: 'theme-orange',
  //   theme: T('SYS.COLOR.ORANGE'),
  //   preview: '#e65100',
  // },
];

export const getThemeColors = () => {
  const body = document.querySelector('body');
  return [
    {
      ['--bg-primary']: getComputedStyle(body)
        .getPropertyValue('--bg-primary')
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
  ];
};
