package notify

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/lib/pq"
	"google.golang.org/protobuf/types/known/emptypb"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skylog.git/skylog"
)

//Service struct
type Service struct {
	Clients        map[chan string]bool
	NewClients     chan chan string
	DefunctClients chan chan string
	Messages       chan string
}

//NewService function return new Service struct instance
func NewService() *Service {
	return &Service{
		make(map[chan string]bool),
		make(chan (chan string)),
		make(chan (chan string)),
		make(chan string),
	}
}

//Start function
func (service *Service) Start() {
	go func() {
		for {
			select {
			case s := <-service.NewClients:
				service.Clients[s] = true
				skylog.Error("Added new client")

			case s := <-service.DefunctClients:
				delete(service.Clients, s)
				close(s)
				skylog.Error("Removed client")

			case msg := <-service.Messages:
				for s := range service.Clients {
					s <- msg
				}
				skylog.Error("Broadcast message to %d clients", len(service.Clients))
			}
		}
	}()
}

//DatabaseListenerHandler function
func (service *Service) DatabaseListenerHandler(_ *emptypb.Empty, stream pt.NotifyService_DatabaseListenerHandlerServer) error {
	messageChan := make(chan string)
	service.NewClients <- messageChan

	// notify := w.(http.CloseNotifier).CloseNotify()
	// go func() {
	// 	// <-notify
	// 	service.DefunctClients <- messageChan
	// 	log.Println("HTTP connection just closed.")
	// }()

	for {
		msg, open := <-messageChan
		if !open {
			break
		}

		res := pt.DatabaseListenerResponse{Json: msg}
		skylog.Info(msg)
		stream.Send(&res)
	}

	return nil
}

//WaitForNotification function
func WaitForNotification(l *pq.Listener, service *Service) {
	for {
		select {
		case n := <-l.Notify:
			if n != nil {
				skylog.Error("Received data from channel [", n.Channel, "] :")
				// Prepare notification payload for pretty print
				var prettyJSON bytes.Buffer
				err := json.Indent(&prettyJSON, []byte(n.Extra), "", "\t")
				if err != nil {
					fmt.Println("Error processing JSON: ", err)
					return
				}

				service.Messages <- strings.ReplaceAll(string(prettyJSON.Bytes()), "\n", "")
			}
			return
		case <-time.After(90 * time.Second):
			fmt.Println("Received no events for 90 seconds, checking connection")
			go func() {
				l.Ping()
			}()
			return
		}
	}
}
