package friendaoke.services;

import javafx.concurrent.Service;
import javafx.concurrent.Task;

import java.io.DataInputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class CommandService extends Service<Void> {

    private final static int COMMAND_SERVICE_PORT = 9091;

    private ServerSocket serverSocket = null;
    private DataInputStream in = null;

    @Override
    protected Task<Void> createTask() {
        return new Task<>() {
            @Override
            protected Void call() throws Exception {
                serverSocket = new ServerSocket(COMMAND_SERVICE_PORT);
                Socket clientSocket = serverSocket.accept();
                in = new DataInputStream(clientSocket.getInputStream());
                while (true) {
                    String command;
                    if (!((command = in.readUTF()) == null)) {
                        updateMessage(command);
                    }
                }
//                return null;
            }
        };
    }

    @Override
    public boolean cancel() {
        try {
            serverSocket.close();
            if (in != null)
                in.close();
        } catch (IOException e) {
            e.printStackTrace();
            return super.cancel();
        }
        return super.cancel();
    }
}
