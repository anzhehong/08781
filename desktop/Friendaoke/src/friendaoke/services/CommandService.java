package friendaoke.services;

import com.google.gson.Gson;
import friendaoke.VideoInfoBean;
import javafx.concurrent.Service;
import javafx.concurrent.Task;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.List;

import static friendaoke.Controller.VIDEO_LIST_REQUEST;

public class CommandService extends Service<Void> {

    private final static int COMMAND_SERVICE_PORT = 9091;

    private ServerSocket serverSocket = null;
    private DataInputStream in = null;

    private List<VideoInfoBean> videoInfoBeanList;

    public CommandService(List<VideoInfoBean> videos) {
        super();
        videoInfoBeanList = videos;
    }

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
                        if (command.equals(VIDEO_LIST_REQUEST)) {
                            sendVideoInfo(clientSocket);
                        } else {
                            updateMessage(command);
                        }
                    }
                }
//                return null;
            }
        };
    }

    private void sendVideoInfo(Socket clientSocket) {
        Gson gson = new Gson();
        String video = gson.toJson(videoInfoBeanList);
        DataOutputStream out;
        try {
            out = new DataOutputStream(clientSocket.getOutputStream());
            out.writeUTF(video);
        } catch (IOException e) {
            e.printStackTrace();
        }
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
