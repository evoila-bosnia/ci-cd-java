package com.example.cicd;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("test")
public class TestController {

    @GetMapping
    public String test() {
        return "OK";

    }
}
