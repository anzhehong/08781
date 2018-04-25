package friendaoke.services;

import com.google.gson.Gson;
import friendaoke.Controller;
import friendaoke.VideoInfoBean;
import javafx.application.Platform;
import javafx.concurrent.Service;
import javafx.concurrent.Task;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.List;

import static friendaoke.Controller.*;

public class CommandService extends Service<Void> {

    private final static int COMMAND_SERVICE_PORT = 9091;

    private ServerSocket serverSocket = null;
    private DataInputStream in = null;

    private Controller controller;
    private List<VideoInfoBean> videoInfoBeanList;

    public CommandService(Controller controller, List<VideoInfoBean> videos) {
        super();
        this.controller = controller;
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
                String actualCommand = "PAUS";
                while (true) {
                    updateMessage("");
                    byte[] data = new byte[1024];
                    in.read(data);
                    String command = new String(data, "UTF-8");

                    if (command.startsWith(VIDEO_LIST_REQUEST)) {
                        sendVideoInfo(clientSocket);
                    } else if (command.startsWith(PLAY)) {
                        Platform.runLater(() -> controller.onPlayButtonClick(null));
                    } else if (command.startsWith(NEXT)) {
                        Platform.runLater(() -> {
                            controller.onPlayButtonClick(null);
                            controller.nextMedia();
                            controller.onPlayButtonClick(null);
                        });
                    } else if (command.startsWith(PREVIOUS)) {
                        Platform.runLater(() -> {
                            controller.onPlayButtonClick(null);
                            controller.prevMedia();
                            controller.onPlayButtonClick(null);
                        });
                    } else if (command.startsWith(VOLUME_DOWN)) {
                        Platform.runLater(() -> controller.setVolumeDown());
                    } else if (command.startsWith(VOLUME_UP)) {
                        Platform.runLater(() -> controller.setVolumeUp());
                    } else if (command.startsWith(SELECT)) {
                        actualCommand = SELECT;
                        updateMessage(actualCommand);
                    }
                    System.out.println("command: " + command);
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
