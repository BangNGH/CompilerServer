package com.example.compiler_server;

public class Submission {
    private String language;
    private String stdin;
    private String source_code;
    private String expected_output;

    public String getExpected_output() {
        return expected_output;
    }

    public void setExpected_output(String expected_output) {
        this.expected_output = expected_output;
    }
    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getStdin() {
        return stdin;
    }

    public void setStdin(String stdin) {
        this.stdin = stdin;
    }

    public String getSource_code() {
        return source_code;
    }

    public void setSource_code(String source_code) {
        this.source_code = source_code;
    }


    // Các getters và setters khác nếu cần
}
