import { getRandomInt } from 'src/lib/random';

let passwordChars = ['○', '☺', '☓', '✳', '✾', '✌', '♛'];

export const passwordChar = () => {
  const randIndex = getRandomInt(0, passwordChars.length - 1);
  return passwordChars[randIndex];
};
