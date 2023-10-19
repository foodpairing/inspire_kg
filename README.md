# Inspire KG

The Inspire KG is an RDF Knowledge Graph (KG) that contains the following:

- Ingredient category taxonomy (139 categories, 4 layers);
- 102 ingredients from the Foodpairing® DB;
- Sensory information (aromas, tastes, textures, trigeminals);
- Functional benefits;
- Ingredient pairings.

The Inspire KG is based on our own [Inspiration Tool](https://inspire.foodpairing.com/) for trying out ingredient
combinations and contains a small subset of the knowledge that is available in
our [in-house Enterprise KG](https://www.foodpairing.com/industry/research-fundamental/enterprise-wide-knowledge-graph/).

## Relevant Resources

The Inspire KG is freely available under [CC BY 4.0 DEED](LICENSE.md) for download from [here](inspire.ttl). Its
specification is
available [here](https://foodpairing.github.io/inspire_kg/), while the rest of this page presents some more technical
use cases.

## Use Cases

Below are some illustrative use cases (in the form of SPARQL queries) demonstrating the practical use of the Inspire KG.

### Ingredient Categories Taxonomy

<details>
 <summary>Retrieve category information</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?category_name ?category_definition ?broader_category_name WHERE {
    ?c a :IngredientCategory ;
        skos:prefLabel ?category_name ;
        skos:definition ?category_definition .
    OPTIONAL {
        # top-level categories do not have a parent category
        ?c skos:broader ?b .
        ?b a :IngredientCategory ;
            skos:prefLabel ?broader_category_name .
    }
}
ORDER BY ?category_name
```

</details>

<details>
 <summary>Count of child categories per parent category</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?parent_category_name (COUNT(DISTINCT ?c) AS ?child_count) WHERE {
    ?p a :IngredientCategory ;
        skos:prefLabel ?parent_category_name .
    ?c a :IngredientCategory ;
        skos:broader ?p .
}
GROUP BY ?parent_category_name ORDER BY ?parent_category_name
```

</details>

### Food Ingredients

<details>
 <summary>Retrieve ingredient information</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?ingredient_name ?ingredient_definition ?ingredient_category_name ?wikidata_link WHERE {
    ?i a :Ingredient ;
        skos:prefLabel ?ingredient_name ;
        skos:definition ?ingredient_definition ;
        :hasIngredientCategory/skos:prefLabel ?ingredient_category_name ;
        rdfs:seeAlso ?wikidata_link .
}
ORDER BY ?ingredient_name
```

</details>

<details>
 <summary>Retrieve ingredients belonging to specific categories</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?ingredient_name ?ingredient_definition ?ingredient_category_name WHERE {
    ?i a :Ingredient ;
        skos:prefLabel ?ingredient_name ;
        skos:definition ?ingredient_definition ;
        :hasIngredientCategory/skos:prefLabel ?ingredient_category_name .
    VALUES ?ingredient_category_name { "Pome Fruits"@en "Tropical Fruits"@en }
}
ORDER BY ?ingredient_name
```

</details>

<details>
 <summary>Retrieve ingredients belonging to a master category</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?ingredient_name WHERE {
    ?i a :Ingredient ;
        skos:prefLabel ?ingredient_name ;
        skos:definition ?ingredient_definition ;
        :hasIngredientCategory ?c .
    # Retrieve ingredients no matter how deep in the categories taxonomy they are
    ?c a :IngredientCategory ;
        skos:broader*/skos:prefLabel "Fruit Category"@en .
}
ORDER BY ?ingredient_name
```

</details>

<details>
 <summary>Federated query over Wikidata</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?ingredient_name ?water_footprint WHERE {
    {
        SELECT * WHERE {
            ?i a :Ingredient ;
                skos:prefLabel ?ingredient_name ;
                rdfs:seeAlso ?wikidata .
            BIND(URI(?wikidata) AS ?wikidataLink)
        }
    }

    # Retrieve water footprint per ingredient (wherever available) from Wikidata
    SERVICE <https://query.wikidata.org/sparql> {
        ?wikidataLink <http://www.wikidata.org/prop/direct/P6000> ?water_footprint .
    }
}
ORDER BY ?ingredient_name ?water_footprint
```

</details>

### Sensory Information

<details>
 <summary>Retrieve aroma information per ingredient</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?ingredient_name ?aroma_label ?sensory_value WHERE {
    ?i a :Ingredient ;
        skos:prefLabel ?ingredient_name ;
        :hasAroma ?a .
    ?a a :Aroma ;
        :sensoryValue ?sensory_value ;
        :hasSensoryDescriptor ?d .
    ?d a :SensoryDescriptor ;
        skos:prefLabel ?aroma_label .
}
ORDER BY ?ingredient_name DESC(?sensory_value)
```

</details>

<details>
 <summary>Retrieve the 3 most dominant aromas for an ingredient</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>

SELECT ?aroma_label ?sensory_value WHERE {
    ?i a :Ingredient ;
        skos:prefLabel "Basil Leaf"@en ;
        :hasAroma ?a .
    ?a a :Aroma ;
        :sensoryValue ?sensory_value ;
        :hasSensoryDescriptor ?d .
    ?d a :SensoryDescriptor ;
        skos:prefLabel ?aroma_label .
}
ORDER BY DESC(?sensory_value) LIMIT 3
```

</details>

<details>
 <summary>Retrieve taste information per ingredient</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?ingredient_name ?taste_label ?sensory_value WHERE {
    ?i a :Ingredient ;
        skos:prefLabel ?ingredient_name ;
        :hasTaste ?t .
    ?t a :Taste ;
        :sensoryValue ?sensory_value ;
        :hasSensoryDescriptor ?d .
    ?d a :SensoryDescriptor ;
        skos:prefLabel ?taste_label .
}
ORDER BY ?ingredient_name DESC(?sensory_value)
```

</details>

<details>
 <summary>Retrieve texture information per ingredient</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?ingredient_name ?texture_label ?sensory_value WHERE {
    ?i a :Ingredient ;
        skos:prefLabel ?ingredient_name ;
        :hasTexture ?t .
    ?t a :Texture ;
        :sensoryValue ?sensory_value ; # texture is true/false
        :hasSensoryDescriptor ?d .
    ?d a :SensoryDescriptor ;
        skos:prefLabel ?texture_label .
}
ORDER BY ?ingredient_name DESC(?sensory_value)
```

</details>

<details>
 <summary>Retrieve trigeminal taste information per ingredient</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?ingredient_name ?trigeminal_label ?sensory_value WHERE {
    ?i a :Ingredient ;
        skos:prefLabel ?ingredient_name ;
        :hasTrigeminal ?t .
    ?t a :Trigeminal ;
        :sensoryValue ?sensory_value ; # trigeminal is true/false
        :hasSensoryDescriptor ?d .
    ?d a :SensoryDescriptor ;
        skos:prefLabel ?trigeminal_label .
}
ORDER BY ?ingredient_name DESC(?sensory_value)
```

</details>

### Functional Benefits

<details>
 <summary>List of functional benefits per ingredient</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?ingredient_name (GROUP_CONCAT(DISTINCT ?functional_benefit; SEPARATOR = ", ") AS ?functional_benefits) WHERE {
    ?i a :Ingredient ;
        skos:prefLabel ?ingredient_name ;
        :hasFunctionalBenefit ?f .
    ?f a :FunctionalBenefit ;
        skos:prefLabel ?functional_benefit .
}
GROUP BY ?ingredient_name ORDER BY ?ingredient_name
```

</details>

<details>
 <summary>Retrieve functional benefits of a specific ingredient</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?functional_benefit ?functional_benefit_definition WHERE {
    ?i a :Ingredient ;
        skos:prefLabel "Vodka"@en ;
        :hasFunctionalBenefit ?f .
    ?f a :FunctionalBenefit ;
        skos:prefLabel ?functional_benefit ;
        skos:definition ?functional_benefit_definition .
}
ORDER BY ?functional_benefit
```

</details>

<details>
 <summary>Retrieve the most popular functional benefits</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?functional_benefit (COUNT(DISTINCT ?i) AS ?ingredient_count) WHERE {
    ?i a :Ingredient ;
        :hasFunctionalBenefit ?f .
    ?f a :FunctionalBenefit ;
        skos:prefLabel ?functional_benefit .
}
GROUP BY ?functional_benefit ORDER BY DESC(?ingredient_count) LIMIT 10
```

</details>

### Ingredient Pairings

<details>
 <summary>Retrieve ingredient pairing information</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?ingredient_pairing ?key_ingredient ?related_ingredient ?foodpairing_match_score WHERE {
    ?p a :IngredientPairing ;
        skos:prefLabel ?ingredient_pairing ;
        :hasKeyIngredient/skos:prefLabel ?key_ingredient ;
        :hasRelatedIngredient/skos:prefLabel ?related_ingredient ;
        :matchScore ?foodpairing_match_score .
}
ORDER BY ?key_ingredient DESC(?foodpairing_match_score)
```

</details>

<details>
 <summary>Best matchings for a specific ingredient</summary>

```sparql
PREFIX : <https://w3id.org/foodpairing_inspire_kg#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?ingredient_pairing ?related_ingredient ?foodpairing_match_score WHERE {
    ?p a :IngredientPairing ;
        skos:prefLabel ?ingredient_pairing ;
        :hasKeyIngredient/skos:prefLabel "Strawberry"@en ;
        :hasRelatedIngredient/skos:prefLabel ?related_ingredient ;
        :matchScore ?foodpairing_match_score .
}
ORDER BY DESC(?foodpairing_match_score) LIMIT 10
```

</details>

## Wanna See More?

In case you detect any problems or if you would like to have more information added to the Inspire KG, please do not
hesitate [to create an issue](https://github.com/foodpairing/inspire_kg/issues), and we will shortly try to address it.