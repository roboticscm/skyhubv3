package file

import (
	"bytes"
	"fmt"
	"os"
	"path/filepath"
	"sync"

	"github.com/google/uuid"
	"suntech.com.vn/skygroup/config"
	"suntech.com.vn/skylib/skylog.git/skylog"
)

//FileStore interface
type FileStore interface {
	SaveToDisk(category, fileType string, data []byte) (fileSystemId int64, filePath, fileName string, fileSize int64, error error)
	DeleteFile(fileSystemID int64, filePath, fileName string) error
}

//Store struct
type Store struct {
	mutex sync.RWMutex
}

//NewStore function
func NewStore() *Store {
	return &Store{}
}

func (store *Store) SaveToDisk(category, fileType string, data []byte) (fileSystemId int64, filePath, fileName string, fileSize int64, err error) {
	store.mutex.Lock()
	defer store.mutex.Unlock()
	newID, _ := uuid.NewRandom()
	fileName = fmt.Sprintf("%v.%v", newID, fileType)
	fileSystemId = 12345
	if category == "PROFILE_AVATAR" {
		filePath = config.GlobalConfig.ProfileAvatarPath
	}

	if err := os.MkdirAll(filePath, os.ModePerm); err != nil {
		return 0, "", "", 0, skylog.ReturnError(err)
	}

	file, err := os.Create(filepath.Join(filePath, fileName))
	if err != nil {
		return 0, "", "", 0, skylog.ReturnError(err)
	}

	buffer := bytes.NewBuffer(data)
	numByte, err := buffer.WriteTo(file)
	if err != nil {
		return 0, "", "", 0, skylog.ReturnError(err)
	}

	fileSize = numByte

	return fileSystemId, filePath, fileName, fileSize, err
}

func (store *Store) DeleteFile(fileSystemID int64, filePath, fileName string) error {
	if err := os.Remove(filepath.Join(filePath, fileName)); err != nil {
		return skylog.ReturnError(err)
	}
	return nil
}
