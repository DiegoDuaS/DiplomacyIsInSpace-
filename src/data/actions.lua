-- What the operator can do with a time slot. Each action trains one skill.

return {
    order = { "etiquette", "treaties", "drills" },

    etiquette = {
        label = "ETIQUETTE WORKSHOP",
        stat = "tact", gain = 2,
        lines = {
            "You rehearse the seven ceremonial bows. Six are enough.",
            "A Kelari greeting: three clicks and a wave. You nail it.",
            "You learn what NOT to say about someone's homeworld.",
        },
    },
    treaties = {
        label = "STUDY TREATIES",
        stat = "logic", gain = 2,
        lines = {
            "You memorize the Concord Accords. All 412 of them.",
            "Clause 9, subsection 3: a loophole. Noted.",
            "Precedent is just yesterday's improvisation. Useful.",
        },
    },
    drills = {
        label = "STANDOFF DRILLS",
        stat = "resolve", gain = 2,
        lines = {
            "You hold a stern stare for a full minute. Nobody blinks.",
            "You practice saying 'no' in four alien dialects.",
            "Shoulders back. Chin up. The mirror flinches first.",
        },
    },
}
