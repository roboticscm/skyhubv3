export const findAvatar = (list, id) => {
  const index = list.findIndex((it) => it.id == id);
  if (index >= 0) {
    return list[index].lowIconData;
  } else {
    return null;
  }
};
