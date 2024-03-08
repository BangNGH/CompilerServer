package com.example.compiler_server;

public class Submission {
    private String language;
    private String stdin;
    private String source_code;

    public String getLanguage() {
        return language;
    }

    @Override
    public String toString() {
        return "Submission{" +
                "language='" + language + '\'' +
                ", stdin='" + stdin + '\'' +
                ", source_code='" + source_code + '\'' +
                '}';
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
