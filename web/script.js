let isVisible = false;
let selectedScenarioName = '';
let currentTab = 'scenarios-list';

function switchTab(tabName) {
    currentTab = tabName;
    
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
    
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(tabName + '-tab').classList.add('active');
    
    if (tabName === 'animations') {
        document.getElementById('animation').focus();
    } else if (tabName === 'scenarios-list') {
        document.getElementById('scenario-search').focus();
    }
}

function toggleUI() {
    isVisible = !isVisible;
    const container = document.querySelector('.container');
    
    if (isVisible) {
        container.style.display = 'block';
        document.getElementById('scenario-search').focus();
        filterScenarios();
    } else {
        container.style.display = 'none';
    }
}

function closeUI() {
    isVisible = false;
    document.querySelector('.container').style.display = 'none';
    
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).catch(error => {
    });
}

function openUI() {
    isVisible = true;
    const container = document.querySelector('.container');
    container.style.display = 'block';
    document.getElementById('scenario-search').focus();
    filterScenarios();
}

function searchScenarios(searchTerm) {
    if (!searchTerm || searchTerm.trim() === '') {
        populateScenarioResults([]);
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/searchScenarios`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            searchTerm: searchTerm.trim()
        })
    })
    .then(response => response.json())
    .then(data => {
        populateScenarioResults(data.scenarios || []);
    })
    .catch(error => {
        populateScenarioResults([]);
    });
}

function populateScenarioResults(scenarios = []) {
    const resultsContainer = document.getElementById('scenario-results');
    const error = document.getElementById('error-scen-list');
    
    if (scenarios.length === 0) {
        resultsContainer.innerHTML = '<div class="no-results">No scenarios found</div>';
        error.textContent = '';
        return;
    }
    
    resultsContainer.innerHTML = '';
    
    if (scenarios.length === 0) {
        resultsContainer.innerHTML = '<div class="no-results">No scenarios found</div>';
        error.textContent = '';
        return;
    }
    
    scenarios.forEach(scenario => {
        const div = document.createElement('div');
        div.className = 'scenario-result-item';
        div.textContent = scenario.name;
        
        div.addEventListener('click', () => {
            document.querySelectorAll('.scenario-result-item').forEach(item => {
                item.classList.remove('selected');
            });
            
            div.classList.add('selected');
            selectedScenarioName = scenario.name;
            
            showScenarioInfo(scenario);
        });
        
        resultsContainer.appendChild(div);
    });
    
    error.textContent = '';
}

function showScenarioInfo(scenario) {
    const error = document.getElementById('error-scen-list');
    
    let entityType = 'ped';
    if (selectedScenarioName.includes('WORLD_ANIMAL_')) {
        entityType = 'animal';
    } else if (selectedScenarioName.includes('PROP_')) {
        entityType = 'prop';
    }
    
    let genderInfo = '';
    if (entityType === 'ped' && scenario.conditional_anims && scenario.conditional_anims.length > 0) {
        const maleAnims = scenario.conditional_anims.filter(anim => anim.includes('_MALE_'));
        const femaleAnims = scenario.conditional_anims.filter(anim => anim.includes('_FEMALE_'));
        
        if (femaleAnims.length > 0 && maleAnims.length === 0) {
            genderInfo = ' (female ped)';
        } else if (femaleAnims.length > 0 && maleAnims.length > 0) {
            genderInfo = ' (both peds)';
        } else {
            genderInfo = ' (male ped)';
        }
    }
    
    error.textContent = `Type: ${entityType}${genderInfo} | Animations: ${scenario.conditional_anims ? scenario.conditional_anims.length : 0}`;
}

function filterScenarios() {
    const searchTerm = document.getElementById('scenario-search').value;
    searchScenarios(searchTerm);
}

function applyScenarioFromList() {
    if (!isVisible) return;
    
    const error = document.getElementById('error-scen-list');
    
    if (!selectedScenarioName) {
        error.textContent = 'Select a scenario first!';
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/getScenarioDetails`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            scenarioName: selectedScenarioName
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success && data.scenario) {
            const scenario = data.scenario;
            
            let entityType = 'ped';
            if (selectedScenarioName.includes('WORLD_ANIMAL_')) {
                entityType = 'animal';
            } else if (selectedScenarioName.includes('PROP_')) {
                entityType = 'prop';
            }
            
            let detectedGender = 'male';
            if (entityType === 'ped' && scenario.conditional_anims && scenario.conditional_anims.length > 0) {
                const maleAnims = scenario.conditional_anims.filter(anim => anim.includes('_MALE_'));
                const femaleAnims = scenario.conditional_anims.filter(anim => anim.includes('_FEMALE_'));
                
                if (femaleAnims.length > 0 && maleAnims.length === 0) {
                    detectedGender = 'female';
                } else if (femaleAnims.length > 0 && maleAnims.length > 0) {
                    detectedGender = Math.random() < 0.5 ? 'male' : 'female';
                }
            }
            
            fetch(`https://${GetParentResourceName()}/applyScenarioFromList`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    scenario: selectedScenarioName,
                    gender: detectedGender,
                    conditionalAnim: scenario.conditional_anims ? scenario.conditional_anims[0] : ''
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    let entityText = '';
                    if (entityType === 'animal') {
                        entityText = 'Animal';
                    } else if (entityType === 'prop') {
                        entityText = 'Prop';
                    } else {
                        if (scenario.conditional_anims && scenario.conditional_anims.length > 0) {
                            const maleAnims = scenario.conditional_anims.filter(anim => anim.includes('_MALE_'));
                            const femaleAnims = scenario.conditional_anims.filter(anim => anim.includes('_FEMALE_'));
                            
                            if (femaleAnims.length > 0 && maleAnims.length === 0) {
                                entityText = 'female ped';
                            } else if (femaleAnims.length > 0 && maleAnims.length > 0) {
                                entityText = 'both peds';
                            } else {
                                entityText = 'male ped';
                            }
                        } else {
                            entityText = 'male ped';
                        }
                    }
                    error.textContent = `Scenario applied: ${selectedScenarioName} (${entityText})`;
                } else {
                    error.textContent = data.error || 'Error applying scenario';
                }
            })
            .catch(error => {
                error.textContent = 'Error applying scenario';
            });
        } else {
            error.textContent = 'Error getting scenario details';
        }
    })
    .catch(error => {
        error.textContent = 'Error getting scenario details';
    });
}

function copyScenarioName() {
    if (!isVisible) return;
    
    const error = document.getElementById('error-scen-list');
    
    if (!selectedScenarioName) {
        error.textContent = 'Select a scenario first!';
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/getScenarioDetails`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            scenarioName: selectedScenarioName
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success && data.scenario) {
            const scenario = data.scenario;
            const scenarioInfo = `${selectedScenarioName} | Animations: ${scenario.conditional_anims ? scenario.conditional_anims.join(', ') : 'None'}`;
            
            if (navigator.clipboard && window.isSecureContext) {
                navigator.clipboard.writeText(scenarioInfo).then(() => {
                    error.textContent = 'Scenario name copied to clipboard!';
                    setTimeout(() => {
                        error.textContent = '';
                    }, 3000);
                }).catch(() => {
                    fallbackCopyTextToClipboard(scenarioInfo);
                });
            } else {
                fallbackCopyTextToClipboard(scenarioInfo);
            }
        } else {
            error.textContent = 'Error getting scenario details';
        }
    })
    .catch(error => {
        error.textContent = 'Error getting scenario details';
    });
}

function fallbackCopyTextToClipboard(text) {
    const textArea = document.createElement('textarea');
    textArea.value = text;
    textArea.style.position = 'fixed';
    textArea.style.left = '-999999px';
    textArea.style.top = '-999999px';
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    
    try {
        document.execCommand('copy');
        const error = document.getElementById('error-scen-list');
        error.textContent = 'Scenario name copied to clipboard!';
        setTimeout(() => {
            error.textContent = '';
        }, 3000);
    } catch (err) {
        const error = document.getElementById('error-scen-list');
        error.textContent = `Failed to copy. Details: ${text}`;
        setTimeout(() => {
            error.textContent = '';
        }, 5000);
    }
    
    document.body.removeChild(textArea);
}

function stopScenario() {
    if (!isVisible) return;
    
    fetch(`https://${GetParentResourceName()}/stopScenario`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    })
    .then(response => response.json())
    .then(data => {
        const error = document.getElementById('error-scen-list');
        if (data.success) {
            error.textContent = 'Scenario stopped successfully!';
        } else {
            error.textContent = data.error || 'Error stopping scenario';
        }
    })
    .catch(error => {
        const errorElement = document.getElementById('error-scen-list');
        errorElement.textContent = 'Error stopping scenario';
    });
}

function applyAnimation() {
    if (!isVisible) return;
    
    const animationInput = document.getElementById('animation');
    const animationText = animationInput.value.trim();
    const error = document.getElementById('error-anim');
    
    if (!animationText) {
        error.textContent = 'Enter a valid animation';
        return;
    }
    
    const spaceIndex = animationText.indexOf(' ');
    if (spaceIndex === -1) {
        error.textContent = 'Invalid format. Use: [dict] [name]';
        return;
    }
    
    const dict = animationText.substring(0, spaceIndex);
    const name = animationText.substring(spaceIndex + 1);
    
    if (!dict || !name) {
        error.textContent = 'Dict and name are required';
        return;
    }
    
    error.textContent = '';
    
    fetch(`https://${GetParentResourceName()}/applyAnimation`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            dict: dict,
            name: name
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            error.textContent = 'Animation applied successfully!';
            animationInput.value = '';
        } else {
            error.textContent = data.error || 'Error applying animation';
        }
    })
    .catch(error => {
        error.textContent = 'Error applying animation';
    });
}

function stopAnimation() {
    if (!isVisible) return;
    
    fetch(`https://${GetParentResourceName()}/stopAnimation`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    })
    .then(response => response.json())
    .then(data => {
        const error = document.getElementById('error-anim');
        if (data.success) {
            error.textContent = 'Animation stopped successfully!';
        } else {
            error.textContent = data.error || 'Error stopping animation';
        }
    })
    .catch(error => {
        const errorElement = document.getElementById('error-anim');
        errorElement.textContent = 'Error stopping animation';
    });
}

document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('scenario-search').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            filterScenarios();
        }
    });
    
    document.getElementById('animation').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            applyAnimation();
        }
    });
    
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && isVisible) {
            e.preventDefault();
            closeUI();
        }
    });
    
    window.addEventListener('message', function(event) {
        if (event.data.type === 'show') {
            openUI();
        } else if (event.data.type === 'hide') {
            closeUI();
        }
    });
});