package friendaoke.services;

import javafx.concurrent.Service;
import javafx.concurrent.Task;

import javax.sound.sampled.*;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.ServerSocket;
import java.net.Socket;

public class VoiceStreamService extends Service<Void> {

    private final static int VOICE_STREAM_SERVICE_PORT = 9090;
    private final static int VOICE_STREAM_SERVICE_UDP_PORT = 9099;

    private SourceDataLine line = null;
    private ServerSocket serverSocket = null;

    private DatagramSocket UDPServerSocket = null;


    @Override
    protected Task<Void> createTask() {
        return new Task<>() {
            @Override
            protected Void call() throws Exception {
                startListening();
                return null;
            }
        };
    }

    @Override
    public boolean cancel() {
        if (UDPServerSocket != null) {
            UDPServerSocket.close();
        }
        if (line != null) {
            line.close();
        }
        return super.cancel();
    }

    private void startListening() {
        try {
//            serverSocket = new ServerSocket(VOICE_STREAM_SERVICE_PORT);
//            System.out.println("waiting...");
//            Socket clientSocket = serverSocket.accept();
//            System.out.println("connected");

            UDPServerSocket = new DatagramSocket(VOICE_STREAM_SERVICE_UDP_PORT);
            startVoiceLineUDP(UDPServerSocket);
//            startVoiceLine(clientSocket);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void startVoiceLineUDP(DatagramSocket UDPServerSocket) throws LineUnavailableException, IOException {
        AudioFormat format = new AudioFormat(
                AudioFormat.Encoding.PCM_SIGNED,
                44100,
                16,
                1,
                2,
                44100,
                false);

        DataLine.Info info = new DataLine.Info(SourceDataLine.class, format);
        line = (SourceDataLine) AudioSystem.getLine(info);
        line.open(format);
        line.start();

        byte[] buf = new byte[4410];
        DatagramPacket packet
                = new DatagramPacket(buf, buf.length);

        while (true) {
            try {
                UDPServerSocket.receive(packet);
            } catch (Exception e) {
                e.printStackTrace();
                break;
            }
            line.write(packet.getData(), 0, packet.getData().length);
        }
    }

    private void startVoiceLine(Socket clientSocket) throws LineUnavailableException, IOException {
        AudioFormat format = new AudioFormat(
                AudioFormat.Encoding.PCM_SIGNED,
                44100,
                16,
                1,
                2,
                44100,
                false);

        DataLine.Info info = new DataLine.Info(SourceDataLine.class, format);
        line = (SourceDataLine) AudioSystem.getLine(info);
        line.open(format);
        line.start();

        InputStream input = new DataInputStream(clientSocket.getInputStream());

        byte[] data = new byte[2];

        while (true) {
            input.read(data);
            line.write(data, 0, data.length);
        }
    }
}
