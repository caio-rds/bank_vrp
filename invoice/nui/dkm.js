const checkbox = document.getElementById('checkbox')
const bodyDarkAndLight = document.querySelector('.container')

checkbox.addEventListener('click', () => {
    if (checkbox.checked) {
        bodyDarkAndLight.classList.add('dark')        
        localStorage.setItem('checkBoxSKR','checked')
    } else {
        bodyDarkAndLight.classList.remove('dark')
        localStorage.setItem('checkBoxSKR','unchecked')
    }
})

if (localStorage.getItem('checkBoxSKR') === 'checked') {
    bodyDarkAndLight.classList.add('dark')
    checkbox.checked = true
}