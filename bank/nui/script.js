// -----------------------------------------------------------------------------------------------------------------------------------------
// -- INIT FRONT
// -----------------------------------------------------------------------------------------------------------------------------------------
$(document).ready(function () {
	window.addEventListener("message", function (event) {
        switch (event.data.action) {
            case "open":    
                $(".main-container").fadeIn(500);            
                $('#open-invoices').addClass('actived');    
                setPageInvoice('open-invoices');
               
                $('#withdraw').addClass('actived');
                setPageOpt('withdraw');
                init();
            break;

            case "close":
                $(".main-container").fadeOut(500);
            break;
        }
	});
	document.onkeyup = function (data) {
		if (data.which == 27) {
			$.post("http://bank/exit");
            $('.btn-invoices').removeClass('actived');
            $('.btn-opt').removeClass('actived');
		}
	};
});
// -----------------------------------------------------------------------------------------------------------------------------------------
// -- LOAD MAIN INFOS - NAME - INVOICES - FINES
// -----------------------------------------------------------------------------------------------------------------------------------------
function init(){
    $.post('http://bank/getInfos', JSON.stringify({}),(data) => {
        $('.name-head').html(`${data.result.nome} ${data.result.sobrenome}`);
        $('.cash-head').html(formatMoney(data.result.saldo));
    });

    listFines();
};
// -----------------------------------------------------------------------------------------------------------------------------------------
// -- FUNCTION TO CHANGE OPTION (WITHDRAW, DEPOSIT AND TRANSFER)
// -----------------------------------------------------------------------------------------------------------------------------------------
$(document).on('click','.btn-opt', function(){   
    let isActive = $(this).hasClass('actived');  
    if (!isActive) {
        $('.btn-opt').removeClass('actived');        
        $(this).addClass('actived');
        setPageOpt($(this).attr('id'));
    }
});
// -----------------------------------------------------------------------------------------------------------------------------------------
// -- CHANGE CONTAINER OPT (PARAMETER PASSED BY ELEMENT ID)
// -----------------------------------------------------------------------------------------------------------------------------------------
function setPageOpt(section){
    if (section == 'withdraw'){
        $('.container-opt').html(`<div class="mini-cont-inside-opt" style="margin-top:40px">
            Valor: <input type="text" class="value-in">
        </div>
        <div class="button-opt" id='${section}' style="margin-top: 45px;">SACAR</div>`);

    }else if (section == 'deposit'){
        $('.container-opt').html(`<div class="mini-cont-inside-opt" style="margin-top:40px">
            Valor: <input type="text" class="value-in">
        </div>
        <div class="button-opt" id='${section}' style="margin-top: 45px;">DEPOSITAR</div>`);

    }else if (section == 'transfer'){
        $('.container-opt').html(`
        <div class="mini-cont-inside-opt" style="padding-left:25px;width:395px;">
            Passaporte: <input type="text" class="transfer-in">
        </div>
        <div class="mini-cont-inside-opt">
            Valor: <input type="text" class="value-in">
        </div>     
        <div class="button-opt" id='${section}'>TRANSFERIR</div>`);
    }
}
// -----------------------------------------------------------------------------------------------------------------------------------------
// -- BUTTON TO MAKE THE OPERATION (THERE'S A MINIMAL VALIDATE)
// -----------------------------------------------------------------------------------------------------------------------------------------
$(document).on('click','.button-opt', function(){   
    let section = $(this).attr('id')
    let val = $('.value-in').val()
    if (section == 'withdraw'){       
        if (val != []){
            if (parseInt(val) > 0 ){
                $.post("http://bank/withdraw",JSON.stringify({valor: val}),(data) => {if(data.withdraw){init()}}); 
                
                $('.value-in').val('');
            }else{              
                $('.value-in').val('');
                $('.value-in').focus();
                notify('vermelho','o valor não pode estar negativo.');
            };
        }else{
            $('.value-in').val('');
            $('.value-in').focus();
            notify('vermelho','o valor não pode estar nulo.');
        };
    }else if (section == 'deposit'){
        if (val != []){
            if (parseInt(val) > 0 ){
                $.post("http://bank/deposit",JSON.stringify({valor: val}),(data) => {if(data.deposit){init()}});
                $('.value-in').val('');
                $('.value-in').focus();            
            }else{
                notify('vermelho','o valor não pode estar negativo.');
            };
        }else{
            notify('vermelho','o valor não pode estar nulo.');
        };
    }else if (section == 'transfer'){
        let id = $('.transfer-in').val()     
        if (id != []){
            if (id > 0){
                if (val != []){
                    if (parseInt(val) > 0){
                        $.post("http://bank/transfer",JSON.stringify({valor: val, pessoa: id}),(data) => {if(data.transfer){init()}});
                        $('.value-in').val('');
                        $('.transfer-in').val('');
                        $('.value-in').focus();
                    }else{
                        notify('vermelho','o valor não pode estar negativo.');
                    };
                }else{
                    notify('vermelho','O valor não pode estar nulo.');
                };
            }else{
                notify('vermelho','IDs não podem ser negativos.');
            };
        } else {
            notify('vermelho','ID não pode estar nulo.');
        };
    };
});
// -----------------------------------------------------------------------------------------------------------------------------------------
// -- BUTTON TO CHANGE OPTIONS IN INVOICES (NOT PAID, PAID, IN WAIT)
// -----------------------------------------------------------------------------------------------------------------------------------------
$(document).on('click','.btn-invoices', function(){   
    let isActive = $(this).hasClass('actived');
    if (!isActive) {
        $('.btn-invoices').removeClass('actived');
        $(this).addClass('actived');
        setPageInvoice($(this).attr('id'))
    }
});
// -----------------------------------------------------------------------------------------------------------------------------------------
// -- CHANGE CONTAINER INVOICES (PARAMETER PASSED BY ELEMENT ID)
// -----------------------------------------------------------------------------------------------------------------------------------------
function setPageInvoice(section){    
    if (section === 'open-invoices'){        
        $.post("http://bank/getInvoices",JSON.stringify({}),({result}) => {
            //console.log(JSON.stringify(result[0]?.id));
            if(result[0]?.id){   
                $('.container-invoices').html(`
                    ${result.map((item) => (`
                        <div class="block-invoices">
                        <div class="head-invoices">● ${item.motivo}</div>
                        <div class="btn-pay-inv" op="pay" valor=${item.valor} id=${item.id}>PAGAR</div>
                        <div class="container-inside-invoice">
                        <div style="margin-left: 2px;">${item.descricao}</div>
                            <div class="details-invoice">
                            <div class="price-invoice">${formatMoney(item.valor)}</div>
                                <div class="date-invoice">${new Date(Number(item.dia)).toLocaleDateString('pt-BR')}</div>
                            </div>
                        </div>
                    </div>`)).join('')}
                    `);
            }else{
                $('.container-invoices').html('<div class="no-invoice">Sem faturas pendentes</div>');
            };    
        });     
    }else if(section === 'paid-invoices'){
        $.post("http://bank/getInvoicesPaid",JSON.stringify({}),({result}) => {
            //console.log(JSON.stringify(result[0]?.id));
            if(result[0]?.id){   
                $('.container-invoices').html(`
                    ${result.map((item) => (`
                        <div class="block-invoices">
                        <div class="head-invoices">● ${item.motivo}</div>
                        <div class="btn-paid-inv" valor=${item.valor} id=${item.id}>PAGO</div>
                        <div class="container-inside-invoice">
                        <div style="margin-left: 2px;">${item.descricao}</div>
                            <div class="details-invoice">
                            <div class="price-invoice">${formatMoney(item.valor)}</div>
                                <div class="date-invoice">${new Date(Number(item.dia)).toLocaleDateString('pt-BR')}</div>
                            </div>
                        </div>
                    </div>`)).join('')}
                `);
            }else{
                $('.container-invoices').html('<div class="no-invoice">Sem faturas pendentes</div>');
            };  
        });        
    }else if(section == 'send-invoices'){
        $.post("http://bank/getInvoicesSender",JSON.stringify({}),({result}) => {      
            if(result[0]?.id){   
                $('.container-invoices').html(`
                    ${result.map((item) => {
                        //console.log(JSON.stringify(result[0]?.id),item.recebido,item.pago);
                        if(item.recebido == 0){
                            if(item.pago == 1){
                                return `<div class="block-invoices">
                                    <div class="head-invoices">● ${item.identidade.name+' '+ item.identidade.name2}</div>
                                    <div class="btn-pay-inv" op="recieve" valor=${item.valor} id=${item.id}>RECEBER</div>
                                    <div class="container-inside-invoice">
                                    <div style="margin-left: 2px;">${item.descricao}</div>
                                        <div class="details-invoice">
                                        <div class="price-invoice">${formatMoney(item.valor)}</div>
                                            <div class="date-invoice">${new Date(Number(item.dia)).toLocaleDateString('pt-BR')}</div>
                                        </div>
                                    </div>
                                </div>`
                            } else {
                                return `<div class="block-invoices">
                                    <div class="head-invoices">● ${item.identidade.name+' '+ item.identidade.name2}</div>
                                    <div class="btn-paid-inv" valor=${item.valor} id=${item.id}>AGUARDE</div>
                                    <div class="container-inside-invoice">
                                    <div style="margin-left: 2px;">${item.descricao}</div>
                                        <div class="details-invoice">
                                        <div class="price-invoice">${formatMoney(item.valor)}</div>
                                            <div class="date-invoice">${new Date(Number(item.dia)).toLocaleDateString('pt-BR')}</div>
                                        </div>
                                    </div>
                                </div>`
                            }
                        } else {
                            return `<div class="no-invoice">Sem faturas pendentes</div>`
                        };

                    }).join('')}
                `);
            
            };  
        });        
    }
};
// -----------------------------------------------------------------------------------------------------------------------------------------
// -- BUTTON PAY-INVOICES
// -----------------------------------------------------------------------------------------------------------------------------------------
$(document).on('click','.btn-pay-inv',
    function()
        {
            let id = $(this).attr('id');
            let valor = $(this).attr('valor');
            let type = $(this).attr('op');
            if(type == 'pay'){
                $.post("http://bank/invoicePayment",JSON.stringify({valor: valor, id: id}),(data) => {                
                    if(data.payment){
                        setPageInvoice('open-invoices');
                    }
                });
            }else if(type == 'recieve'){
                $.post("http://bank/getMoneyMyInv",JSON.stringify({id: id}),(data) => {                   
                    if(data.withdraw){
                        setPageInvoice('send-invoices');
                    }
                });
            }
        }
    );
// -----------------------------------------------------------------------------------------------------------------------------------------
// -- FINES LIST (SIMPLE AND MINIMAL)
// -----------------------------------------------------------------------------------------------------------------------------------------
function listFines(){
    $.post("http://bank/getFines",JSON.stringify({}),({result}) => {
        if(result[0]?.id){    
            $('.container-fines').html(`
                ${result.map((item) => (`
                    <div class="block-fines">
                        <div class="desc-fines">${item.text}</div>
                        <div class="value-fines">${formatMoney(item.price)}</div>
                        <div class="btn-pay-fines" valor=${item.price} id=${item.id}>PAGAR</div>
                    </div>`
                    )).join('')}
                `);
        }else{
            $('.container-fines').html('<div class="no-fines">Sem multas pendentes</div>');
        };    
    });
};
// -----------------------------------------------------------------------------------------------------------------------------------------
// -- BUTTON PAY-FINES
// -----------------------------------------------------------------------------------------------------------------------------------------
$(document).on('click','.btn-pay-fines',
    function()
    {
        let id_fines = $(this).attr('id');
        let valor = $(this).attr('valor');
        $.post("http://bank/finePayment",JSON.stringify({valor: valor, id: id_fines}),(data) => {
            if(data.paid){
                listFines()
            }
        });
    }  
);
// -----------------------------------------------------------------------------------------------------------------------------------------
// -- FUNCTION TO MANIPULATE VALUE AND RETURN IN THE CURRENCY CASH OF COUNTRY
// -----------------------------------------------------------------------------------------------------------------------------------------
function formatMoney(value)
    {
        return new Intl.NumberFormat('pt-BR', {
            style: 'currency',
            currency: 'BRL'
        }).format(value)
    }
// -----------------------------------------------------------------------------------------------------------------------------------------
// -- NOTIFY
// -----------------------------------------------------------------------------------------------------------------------------------------
function notify(type,msg){
    $.post("http://bank/notify",JSON.stringify({type: type,msg: msg}),() => {});
}