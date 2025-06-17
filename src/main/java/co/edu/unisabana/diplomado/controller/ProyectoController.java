package co.edu.unisabana.diplomado.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Slf4j
public class ProyectoController {

    @GetMapping("/mensaje")
    public String mensaje (){
        return "Mensaje de Prueba";
    }

}
