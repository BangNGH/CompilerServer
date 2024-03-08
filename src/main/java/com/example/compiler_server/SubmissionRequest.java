package com.example.compiler_server;

import java.util.List;

public class SubmissionRequest {
    private List<Submission> submissions;

    public List<Submission> getSubmissions() {
        return submissions;
    }

    public void setSubmissions(List<Submission> submissions) {
        this.submissions = submissions;
    }

}
