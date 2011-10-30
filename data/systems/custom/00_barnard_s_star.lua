local s = CustomSystem:new('Barnard\'s star',{ 'STAR_M' })
    :govtype('EARTHCOLONIAL')
    :short_desc('Kolonia karna Federacji Ziemskiej')
    :long_desc([[Barnard's Star to czerwony karzeł o małej masie. Wiek gwiazdy oceniany jest na 7 do 12 miliardów lat, co czyni ją najprawdopodobniej jedną z najstarszych w galaktyce, mimo to, wciąż  jest dość aktywna.  Piloci wchodzący do układu ostrzegani są przed znaczną aktywnością gwiazdy, włączając flary i koronalne wyrzuty masy. Było to jedno z pierwszych miejsc odwiedzonych po wprowadzeniu podroży międzygwiezdnych. Barnard's Star okazała się samotną gwiazdą nieposiadającą planet, jednak ostatecznie zbudowano habitaty, by służyły jako Federalne kolonie karne. Przy wejściu do systemu wymagana jest przepustka od uzbrojonych statków.]])

local barnard = CustomSBody:new('Barnard\'s Star', 'STAR_M')
    :radius(f(17,100))
    :mass(f(16,100))
    :temp(3134)

local barnard_starports = {
    CustomSBody:new('High Security Prison Tranquility', 'STARPORT_ORBITAL')
        :semi_major_axis(f(32,10))
        :rotation_period(f(1,24*60*3)),
    CustomSBody:new('High Security Prison Serenity', 'STARPORT_ORBITAL')
        :semi_major_axis(f(32,10))
        :orbital_offset(f(1,3))
        :rotation_period(f(1,24*60*4)),
}
s:bodies(barnard, barnard_starports)
s:add_to_sector(-1,-1,0,v(0.260,0.993,0.060))
