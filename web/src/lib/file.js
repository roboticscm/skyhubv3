export const getFileExtension = (fileName) => {
    if (!fileName) {
        throw new Error('SYS.MSG.INVALID_FILE_NAME');
    }

    const index = fileName.lastIndexOf('.');
    if (index < 0) {
        throw new Error('SYS.MSG.INVALID_FILE_NAME')
    }

    return fileName.substring(index + 1);
}