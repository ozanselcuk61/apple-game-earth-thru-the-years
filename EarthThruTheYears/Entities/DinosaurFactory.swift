import SpriteKit

enum DinosaurFactory {
    static func dinosaurTypes(for era: Era) -> [DinosaurType] {
        switch era {
        case .triassic:
            return [.coelophysis, .plateosaurus]
        case .jurassic:
            return [.smallRaptor, .largeSauropod, .stegosaurus]
        case .cretaceous:
            return [.tRex, .triceratops, .pterodactyl]
        }
    }

    static func createDinosaur(for era: Era, subLevel: Int) -> Dinosaur {
        let types = dinosaurTypes(for: era)
        let difficultyFactor = CGFloat(subLevel) / 4.0

        // Higher sub-levels introduce tougher dinosaurs
        let availableTypes: [DinosaurType]
        if subLevel <= 2 {
            // Early levels: only use the first (easier) dino type
            availableTypes = Array(types.prefix(max(1, subLevel)))
        } else {
            availableTypes = types
        }

        let selectedType = availableTypes.randomElement() ?? types[0]
        let patrolRange = CGFloat.random(in: 150...(200 + difficultyFactor * 100))
        let dino = Dinosaur(type: selectedType, patrolRange: patrolRange)

        return dino
    }

    static func createDinosaurs(count: Int, era: Era, subLevel: Int, levelWidth: CGFloat) -> [Dinosaur] {
        var dinosaurs: [Dinosaur] = []
        let spacing = levelWidth / CGFloat(count + 1)

        for i in 0..<count {
            let dino = createDinosaur(for: era, subLevel: subLevel)
            let baseX = spacing * CGFloat(i + 1)
            let xOffset = CGFloat.random(in: -50...50)
            let x = (baseX + xOffset).clamped(to: 200...(levelWidth - 200))
            dino.position = CGPoint(x: x, y: Constants.groundHeight + 10)

            let patrolHalf = CGFloat.random(in: 80...150)
            dino.setPatrolBounds(minX: x - patrolHalf, maxX: x + patrolHalf)

            dinosaurs.append(dino)
        }

        return dinosaurs
    }
}
