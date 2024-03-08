package com.example.compiler_server;

import org.springframework.web.bind.annotation.*;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;

@RestController
@CrossOrigin("*")
public class ResultController {

//expect output


    @PostMapping("/submissions/batch")
    @ResponseBody
    public String handleJson(@RequestBody SubmissionRequest submissionRequest) {
        String resourceDirectory = "D:\\Hutech\\DACN\\server\\compiler_server\\src\\main\\resources\\docker";
        String tmpDirectory = resourceDirectory + File.separator + "tmp" + File.separator + UUID.randomUUID().toString();
        File tmpFolder = new File(tmpDirectory);
        if (!tmpFolder.exists()) {
            tmpFolder.mkdirs();
        }
        String inputFilePath = tmpDirectory + File.separator + "input.txt";
        String jsonPath = tmpDirectory + File.separator + "result.json";
        Submission submission;
        for (int i = 0; i < submissionRequest.getSubmissions().size(); i++) {

            submission= submissionRequest.getSubmissions().get(i);
            String action;
            if (i==0){
                action = "ACTION=start";
            }else if (i==(submissionRequest.getSubmissions().size())-1){
                action = "ACTION=stop";
            }
            else action="ACTION=loop";
            if (submissionRequest.getSubmissions().size()==1){
                action = "ACTION=singlefile";
            }
            System.out.println(action);

            if ("java".equals(submission.getLanguage())) {
                String execFilePath = tmpDirectory + File.separator + "Main.java";
                writeSourceCodeNInputFile(submission.getSource_code(), submission.getStdin(), execFilePath, inputFilePath);
                try {
                    String absoluteFilePathToExecute = tmpDirectory + ":/tmp";
                    ProcessBuilder pb = new ProcessBuilder("cmd", "/c", "docker", "run", "--rm", "-e", "COMPILER=java", "-e", "FILE=/tmp/Main.java", "-e", action,"-v", absoluteFilePathToExecute, "java");
                    pb.directory(new File(resourceDirectory));
                    pb.inheritIO();
                    // Bắt đầu tiến trình
                    Process process = pb.start();

                    // Đợi tiến trình kết thúc và in ra kết quả nếu cần
                    int exitCode = process.waitFor();
                    System.out.println("Exit code: " + exitCode);

                } catch (IOException | InterruptedException e) {
                    e.printStackTrace();
                }
            }
            //docker build -t csharp -f csharp/Dockerfile .
           else if ("csharp".equals(submission.getLanguage())) {
                String execFilePath = tmpDirectory + File.separator + "Main.cs";
                writeSourceCodeNInputFile(submission.getSource_code(), submission.getStdin(), execFilePath, inputFilePath);

                try {
                    String absoluteFilePathToExecute = tmpDirectory + ":/tmp";
                    ProcessBuilder pb = new ProcessBuilder("cmd", "/c", "docker", "run", "--rm", "-e", "COMPILER=mcs", "-e", "FILE=/tmp/Main.cs", "-e", action, "-v", absoluteFilePathToExecute, "csharp");
                    pb.directory(new File(resourceDirectory));
                    pb.inheritIO();
                    // Bắt đầu tiến trình
                    Process process = pb.start();

                    // Đợi tiến trình kết thúc và in ra kết quả nếu cần
                    process.waitFor();

                    //nếu main.exe note exists => lấy result.json
                    File mainExeFile = new File(tmpDirectory, "Main.exe");
                    if (!mainExeFile.exists()) {
                        System.out.println("Compile error Main.cs.");
                    } else {
                        ProcessBuilder pb2 = new ProcessBuilder("cmd", "/c", "docker", "run", "--rm", "-e", "COMPILER=mono", "-e", "FILE=/tmp/Main.exe", "-e", action, "-v", absoluteFilePathToExecute, "csharp");
                        pb2.directory(new File(resourceDirectory));
                        pb2.inheritIO();
                        // Bắt đầu tiến trình
                        Process process2 = pb2.start();
                        process2.waitFor();
                        mainExeFile.delete();
                    }


                } catch (IOException | InterruptedException e) {
                    e.printStackTrace();
                }
            }
           else return "Other Language";
        }
        return returnJson(tmpDirectory, tmpFolder);
    }

//Return submission
    @PostMapping("/run")
    @ResponseBody
    public String runJava(@RequestBody String source) throws IOException {

        JsonObject jsonObject = new Gson().fromJson(source, JsonObject.class);
        String language = jsonObject.get("language").getAsString();
        String sourceCode = jsonObject.get("source_code").getAsString();
        String stdin = jsonObject.get("stdin") == null ? null : jsonObject.get("stdin").getAsString();

        String resourceDirectory = "D:\\Hutech\\DACN\\server\\compiler_server\\src\\main\\resources\\docker";
        String tmpDirectory = resourceDirectory + File.separator + "tmp" + File.separator + UUID.randomUUID().toString();
        File tmpFolder = new File(tmpDirectory);
        if (!tmpFolder.exists()) {
            tmpFolder.mkdirs();
        }
        String inputFilePath = tmpDirectory + File.separator + "input.txt";
        String jsonPath = tmpDirectory + File.separator + "result.json";

        //Complete Java Compiler server
        //docker build -t java -f java/Dockerfile .

        if ("java".equals(language)) {
            String execFilePath = tmpDirectory + File.separator + "Main.java";
            writeSourceCodeNInputFile(sourceCode, stdin, execFilePath, inputFilePath);

            try {
                String absoluteFilePathToExecute = tmpDirectory + ":/tmp";
                ProcessBuilder pb = new ProcessBuilder("cmd", "/c", "docker", "run", "--rm", "-e", "COMPILER=java", "-e", "FILE=/tmp/Main.java", "-v", absoluteFilePathToExecute, "java");
                pb.directory(new File(resourceDirectory));
                pb.inheritIO();
                // Bắt đầu tiến trình
                Process process = pb.start();

                // Đợi tiến trình kết thúc và in ra kết quả nếu cần
                int exitCode = process.waitFor();
                System.out.println("Exit code: " + exitCode);

            } catch (IOException | InterruptedException e) {
                e.printStackTrace();
            }

            return returnJson(tmpDirectory, tmpFolder);
        }

        //docker build -t csharp -f csharp/Dockerfile .
        if ("csharp".equals(language)) {
            String execFilePath = tmpDirectory + File.separator + "Main.cs";
            writeSourceCodeNInputFile(sourceCode, stdin, execFilePath, inputFilePath);

            try {
                String absoluteFilePathToExecute = tmpDirectory + ":/tmp";
                ProcessBuilder pb = new ProcessBuilder("cmd", "/c", "docker", "run", "--rm", "-e", "COMPILER=mcs", "-e", "FILE=/tmp/Main.cs", "-v", absoluteFilePathToExecute, "csharp");
                pb.directory(new File(resourceDirectory));
                pb.inheritIO();
                // Bắt đầu tiến trình
                Process process = pb.start();

                // Đợi tiến trình kết thúc và in ra kết quả nếu cần
                process.waitFor();

                //nếu main.exe note exists => lấy result.json
                File mainExeFile = new File(tmpDirectory, "Main.exe");
                if (!mainExeFile.exists()) {
                    System.out.println("Compile error Main.cs.");
                } else {
                    ProcessBuilder pb2 = new ProcessBuilder("cmd", "/c", "docker", "run", "--rm", "-e", "COMPILER=mono", "-e", "FILE=/tmp/Main.exe", "-v", absoluteFilePathToExecute, "csharp");
                    pb2.directory(new File(resourceDirectory));
                    pb2.inheritIO();
                    // Bắt đầu tiến trình
                    Process process2 = pb2.start();
                    process2.waitFor();

                }

            } catch (IOException | InterruptedException e) {
                e.printStackTrace();
            }

            return returnJson(tmpDirectory, tmpFolder);
        }
        return "Other Language";
    }

    //Return json & remove all
    private String returnJson(String tmpDirectory, File tmpFolder) {
        // Đọc nội dung của tệp result.json
        try {
            String resultJsonContent = new String(Files.readAllBytes(Paths.get(tmpDirectory + "/result.json")), StandardCharsets.UTF_8);
             // Xóa file main.java và thư mục tmp sau khi thực thi xong
             //FileUtils.deleteDirectory(tmpFolder);
            return resultJsonContent;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "NULL";
    }

    //write source code & stdin to compile
    private void writeSourceCodeNInputFile(String sourceCode, String stdin, String execFilePath,String inputFilePath) {
        try {

            FileWriter writer = new FileWriter(execFilePath);
            writer.write(sourceCode);
            writer.close();

            if (stdin != null) {
                FileWriter inputWriter = new FileWriter(inputFilePath);
                inputWriter.write(stdin);
                inputWriter.close();
            }
            System.out.println("Đường dẫn file: " + execFilePath);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // Hàm mã hoá Base64
    public static String encode(String input) {
        byte[] encodedBytes = Base64.getEncoder().encode(input.getBytes());
        return new String(encodedBytes);
    }

    // Hàm giải mã Base64
    public static String decode(String input) {
        byte[] decodedBytes = Base64.getDecoder().decode(input);
        return new String(decodedBytes);
    }

}
