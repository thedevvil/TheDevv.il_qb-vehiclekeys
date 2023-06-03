local Translations = {
    notify = {
        ydhk = 'Bu aracın anahtarına sahip değilsiniz.',
        nonear = 'Yakınlarda anahtarları verecek kimse yok',
        vlock = 'Araç kilitli!',
        vunlock = 'Araç kilidi açıldı!',
        vlockpick = 'Kapı kilidini açmayı başardın!',
        fvlockpick = 'Anahtarları bulamıyorsun.',
        vgkeys = 'Anahtarları teslim et.',
        vgetkeys = 'Aracın anahtarını buldun!',
        fpid = 'Oyuncu kimliğini ve plaka bağımsız değişkenlerini doldurun',
        cjackfail = 'Araba hırsızlığı başarısız oldu!',
    },
    progress = {
        takekeys = 'Anahtarı alıyorsun...',
        hskeys = 'Araba anahtarları aranıyor...',
        acjack = 'Araba hırsızlığına teşebbüs...',
    },
    info = {
        skeys = '~g~[H]~w~ - Aracı kurcala',
        tlock = 'Araç kilidini aç',
        palert = 'Araç hırsızlığı devam ediyor. Tip: ',
        engine = 'Motoru çalıştır',
    },
    addcom = {
        givekeys = 'Anahtarları birine teslim edin. ID yoksa en yakın kişiye veya araçtaki herkese verir..',
        givekeys_id = 'id',
        givekeys_id_help = 'Oyuncu ID',
        addkeys = 'Birisi için bir araca anahtar ekler.',
        addkeys_id = 'id',
        addkeys_id_help = 'Oyuncu ID',
        addkeys_plate = 'Plaka',
        addkeys_plate_help = 'Plaka',
        rkeys = 'Birisi için bir aracın anahtarı sil.',
        rkeys_id = 'id',
        rkeys_id_help = 'Oyuncu ID',
        rkeys_plate = 'Plaka',
        rkeys_plate_help = 'Plaka',
    }

}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
