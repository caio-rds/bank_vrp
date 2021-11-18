$(function () {

    function display(bool) {
        if (bool) {
            $(".container").show()
        } else {
            $(".container").hide()
        }
    }

    display(false)

    window.addEventListener('message', function(event) {
        var item = event.data
        if (item.type === "ui") {
            if (item.status == true) {
                display(true)
            } else {
                display(false)
            }
        }
    })

    function fechar() {
        $.post('http://invoice/exit', JSON.stringify({}))
        return
    }

    $("#enviar").on('click', (function () {
        let passaporte = $('#passaporte').val()
        let valor = $('#valor').val()
        let motivo = $('#motivo').val()
        let description = $('#description').val()
        if (!passaporte) {
            Swal.fire(
                'Erro',
                'Alvo não identificado',
                'error'
              )
              return
        } else if (!valor || valor < 1) {
            Swal.fire(
                'Erro',
                'Valor não identificado',
                'error'
              )
              return
        } else if (!motivo) {
            Swal.fire(
                'Erro',
                'Motivo não identificado',
                'error'
              )
              return
        } else if (!description) {
            Swal.fire(
                'Erro',
                'Descrição não identificada',
                'error'
              )
              return
        }
        $.post("http://invoice/enviarFatura",JSON.stringify({
            passaporte,
            valor,
            motivo,
            description
        }))
        $('input').val('');
    }))

    document.onkeyup = function (data) {
        if (data.which == 27) {
            fechar() 
        }
    }

    $("#fechar").on('click', (function () {
        fechar()
    }))

})