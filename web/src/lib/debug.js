export const isDebugMode = () => {
  return process.env.NODE_ENV === 'development' || process.env.NODE_ENV === 'dev';
};

export const log = (...message) => {
  if (isDebugMode()) {
    console.log(message);
  }
};

export const logSection = (section, ...message) => {
  if (isDebugMode()) {
    console.log(`---------${section}--------`);
    console.log(message);
  }
};

export const error = (...message) => {
  if (isDebugMode()) {
    console.error(message);
  }
};

export const errorSection = (section, ...message) => {
  if (isDebugMode()) {
    console.error(`---------${section}--------`);
    console.error(message);
  }
};
