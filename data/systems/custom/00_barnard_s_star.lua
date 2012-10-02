-- Copyright © 2008-2012 Pioneer Developers. See AUTHORS.txt for details
-- Licensed under the terms of the GPL v3. See licenses/GPL-3.txt

local s = CustomSystem:new('Barnard\'s star',{ 'STAR_M' })
    :govtype('EARTHCOLONIAL')
    :short_desc('Kolonia karna Federacji Ziemskiej')
    :long_desc([[Barnard's Star to czerwony karzeł o bardzo małej masie.  Wiek gwiazdy oceniany jest na 7 do 12 miliardów lat, co najprawdopodobniej czyni ją jedną z najstarszych w galaktyce.  Pomimo to, wciąż jest dość aktywna.  Piloci wchodzący do układu ostrzegani są przed znaczną aktywnością gwiazdy, włączając w to flary i koronalne wyrzuty masy.

To od wprowadzenia podróży międzygwiezdnych jedna z pierwszych odwiedzonych gwiazd, a Barnard's Star okazała się gwiazdą samotną, nieposiadającą planet.  Jednak ostatecznie zbudowano habitaty, by służyły jako Federalne kolonie karne.

Zwykle uzyskanie pozwolenia na wejście do tego systemu wymaga posiadania uzbrojenia.]])

local barnard = CustomSystemBody:new('Barnard\'s Star', 'STAR_M')
    :radius(f(17,100))
    :mass(f(16,100))
    :temp(3134)

local barnard_starports = {
    CustomSystemBody:new('High Security Prison Tranquility', 'STARPORT_ORBITAL')
        :semi_major_axis(f(32,10))
        :rotation_period(f(1,24*60*3)),
    CustomSystemBody:new('High Security Prison Serenity', 'STARPORT_ORBITAL')
        :semi_major_axis(f(32,10))
        :orbital_offset(f(1,3))
        :rotation_period(f(1,24*60*4)),
}
s:bodies(barnard, barnard_starports)
s:add_to_sector(-1,0,0,v(0.260,0.007,0.060))
